-- Arquivo principal que aplica as traduções de diálogos, nomes e descrições de itens, movimentos, treinadores e strings.
return function(mod)
  -- Função auxiliar para ler e carregar um catálogo de traduções a partir de um arquivo Lua.
  local function catalog(name)
    local rel = "lang/" .. name .. ".lua"
    local body = mod:read(rel)
    if not body then return {} end
    local chunk, err = loadstring(body, "@" .. rel)
    if not chunk then
      mod.log:warn("%s tem erro de sintaxe: %s", rel, tostring(err))
      return {}
    end
    local ok, table_ = pcall(chunk)
    if not ok or type(table_) ~= "table" then
      mod.log:warn("%s nao retornou uma tabela: %s", rel, tostring(table_))
      return {}
    end
    return table_
  end

  -- Função auxiliar para processar valores de diálogo, convertendo-os em listas de segmentos de texto IR.
  local counts = { comum = 0, propria = 0 }
  local function dialogueValue(value)
    if type(value) ~= "string" then return value end
    local hasDynamic = value:find("{DYNAMIC_%d+}") ~= nil
    local hasExt = value:find(string.char(0xFC), 1, true) ~= nil
    if not hasDynamic and not hasExt then return value end

    local TextIR = require("src.core.game3.scripting.text_ir")
    if not hasDynamic then return TextIR.fromAscii(value) end

    local result, cursor = {}, 1
    local function appendAscii(text)
      for _, segment in ipairs(TextIR.fromAscii(text)) do
        if segment.t ~= "eos" then result[#result + 1] = segment end
      end
    end
    while true do
      local first, last, index = value:find("{DYNAMIC_(%d+)}", cursor)
      if not first then break end
      appendAscii(value:sub(cursor, first - 1))
      result[#result + 1] = { t = "dynamic", n = tonumber(index) }
      cursor = last + 1
    end
    appendAscii(value:sub(cursor))
    result[#result + 1] = { t = "eos" }
    return result
  end

  -- Função auxiliar para aplicar traduções de diálogo a partir de um catálogo, contando quantas traduções foram aplicadas.
  local function applyDialogue(name, bucket)
    for key, value in pairs(catalog(name)) do
      if type(key) == "string"
        and ((type(value) == "string" and (value ~= "" or name == "dialogue"))
          or (type(value) == "table" and #value > 0)) then
        mod.content.text:override(key, dialogueValue(value))
        counts[bucket] = counts[bucket] + 1
      end
    end
  end

  -- Função auxiliar para aplicar traduções de nomes e descrições de movimentos, itens, treinadores e strings a partir de um catálogo.
  local function each(name, apply)
    for id, value in pairs(catalog(name)) do
      if type(value) == "string" and value ~= "" then apply(id, value) end
    end
  end

  -- Início do processo de aplicação das traduções de diálogo, nomes e descrições de itens, movimentos, treinadores e strings.
  -- Aplica primeiro os diálogos comuns aos dois jogos (FireRed e LeafGreen).
  applyDialogue("dialogue", "comum")

  -- Aplica os diálogos específicos de cada jogo, dependendo da versão detectada.
  local vid = "firered"
  local okV, GameVersion = pcall(require, "src.core.GameVersion")
  if okV and GameVersion and GameVersion.get then
    vid = GameVersion.get() or vid
  end
  if vid == "leafgreen" then
    applyDialogue("dialogue_leafgreen", "propria")
  else
    applyDialogue("dialogue_firered", "propria")
  end

  -- Aplica nomes e descrições de movimentos, itens, treinadores e strings
  each("move_names", function(id, value)
    mod.content.moves:patch(id, { name = value })
  end)
  each("item_names", function(id, value)
    mod.content.items:patch(id, { name = value })
  end)
  each("item_descriptions", function(id, value)
    mod.content.items:patch(id, { description = value })
  end)
  each("trainer_class_names", function(id, value)
    mod.content.trainers:patch(id, { className = value })
  end)
  each("strings", function(id, value)
    mod.content.strings:override(id, value)
  end)
  each("strings_by_english", function(id, value)
    mod.content.strings:override(id, value)
  end)

  -- Aplica mudança de unidades de altura e peso no Pokedex, se o módulo estiver presente.
  if pcall(require, "src.core.game3.pokedex_units") then
    for id, value in pairs(catalog("species_metrics")) do
      if type(value) == "table" and value[1] and value[2] then
        mod.content.pokemon:patch(id, {
          dexEntry = { heightM = value[1], weightKg = value[2] },
        })
      end
    end
  end

  -- Aplica traduções de rótulos do menu inicial, se houver.
  local startMenu = catalog("start_menu")
  if next(startMenu) ~= nil then
    mod.hooks:wrap("ui.start_menu.items", function(nextFn, game, items)
      for _, item in ipairs(type(items) == "table" and items or {}) do
        local value = type(item) == "table" and startMenu[item.id]
        if type(value) == "string" and value ~= "" then item.label = value end
      end
      return nextFn(game, items)
    end)
  end

  -- Faz a troca de assets de gráficos (fontes e larguras dos caracteres).
  local Runtime = require("src.mods.Runtime")
  local Cache = require("src.import.CacheFs")

  -- Ligue para ver no log os caminhos de chrome/fonts que o jogo pede ao cache.
  local DEBUG_ASSETS = true
  -- Ligue para logar TODO caminho pedido ao cache (uma vez cada). Barulhento.
  local DEBUG_ALL = false

  local ROOT = "assets/gen3-export/"   -- onde ficam os PNGs exportados
  local CACHE = "data/generated/gba/"  -- prefixo dos caminhos no cache do jogo

  -- Fontes: o cache guarda como .rgba (bytes crus RGBA, sem cabeçalho),
  -- então o PNG do mod é convertido na hora.
  local fonts = {
    "chrome/fonts/latin_normal_fg",
    "chrome/fonts/latin_normal_shadow",
    "chrome/fonts/latin_small_fg",
    "chrome/fonts/latin_small_shadow",
  }
  -- Larguras dos caracteres: arquivos .lua repassados exatamente como estão.
  -- Esquerda = caminho que o jogo pede ao cache; direita = arquivo dentro do mod.
  local widths = {
    ["chrome/fonts/latin_widths.lua"] = "fonts/latin_widths.lua",
    ["chrome/fonts/latin_small_widths.lua"] = "fonts/latin_small_widths.lua",
  }

  local assets = {}
  for _, n in ipairs(fonts) do
    assets[CACHE .. n .. ".rgba"] = { file = ROOT .. n .. ".png", raw = true }
  end
  for cachePath, file in pairs(widths) do
    assets[CACHE .. cachePath] = { file = file }
  end

  -- Descarta fontes/chrome já carregados para que sejam relidos pela ponte.
  local function invalidateImages()
    pcall(function() require("src.ui.game3.chrome").invalidate() end)
    pcall(function() require("src.ui.game3.frlg_font").invalidate() end)
  end

  -- Reaplica a invalidação depois de Runtime.install/reset (ativar, desativar ou recarregar mods).
  if not Runtime._contentEditorLifecycle then
    Runtime._contentEditorLifecycle = true
    for _, name in ipairs({ "install", "reset" }) do
      local original = Runtime[name]
      Runtime[name] = function(...)
        original(...)
        if Cache._contentEditorInvalidate then
          local reset = Cache._contentEditorInvalidate
          Cache._contentEditorInvalidate = nil
          reset()
        end
      end
    end
  end
  Cache._contentEditorInvalidate = invalidateImages

  -- Ponte sobre a leitura do cache (readAt nos runtimes 0.3.5x+, read nos antigos).
  if type(Cache.readAt) == "function" then
    if not Cache._contentEditorBridgeAt then
      Cache._contentEditorBridgeAt = true
      local readAt = Cache.readAt
      Cache.readAt = function(path) return Runtime.call("editor.gen3.cache", readAt, path) end
    end
  elseif not Cache._contentEditorBridge then
    Cache._contentEditorBridge = true
    local read = Cache.read
    Cache.read = function(path) return Runtime.call("editor.gen3.cache", read, path) end
  end

  local memo, seen = {}, {}
  mod.hooks:wrap("editor.gen3.cache", function(proceed, path)
    local key = path:gsub("^" .. require("src.core.GameVersion").cachePrefix(), "")
    if not key:match("^data/generated/gba/") then key = CACHE .. key end
    if DEBUG_ASSETS and not seen[key] and (DEBUG_ALL or key:match("chrome/fonts")) then
      seen[key] = true
      mod.log:info("[assets] cache pediu: %s (substituir=%s)", key, tostring(assets[key] ~= nil))
    end
    local asset = assets[key]
    if not asset then return proceed(path) end
    if not memo[key] then
      local bytes = assert(mod:read(asset.file), "Missing asset " .. asset.file)
      if asset.raw then
        bytes = love.image.newImageData(love.filesystem.newFileData(bytes, "asset.png")):getString()
      end
      memo[key] = bytes
    end
    return memo[key]
  end)

  -- Evento que é disparado quando o jogo estiver pronto
  mod.events:on("game.ready", function()
    -- Loga a quantidade de traduções aplicadas quando o jogo estiver pronto.
    mod.log:info("FireRed Legenda PT-BR [%s]: %d comuns + %d proprios",
      vid, counts.comum, counts.propria)

    -- Faz o jogo reler as fontes (já com os arquivos substituídos).
    invalidateImages()
  end)
end