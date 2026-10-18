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

  -- Loga a quantidade de traduções aplicadas quando o jogo estiver pronto.
  mod.events:on("game.ready", function()
    mod.log:info("FireRed Legenda PT-BR [%s]: %d comuns + %d proprios",
      vid, counts.comum, counts.propria)
  end)
end
