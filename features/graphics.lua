return function(mod)
  -- Os glifos adicionados ocupam as células 0x30-0x33 nas fontes latin_normal e latin_small.
  local FrlgFont = require("src.ui.game3.frlg_font")
  FrlgFont.LATIN_GLYPHS[0x30] = "Ã"
  FrlgFont.LATIN_GLYPHS[0x31] = "Õ"
  FrlgFont.LATIN_GLYPHS[0x32] = "ã"
  FrlgFont.LATIN_GLYPHS[0x33] = "õ"
  FrlgFont.invalidate()

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

  mod.events:on("game.ready", function()
    -- Faz o jogo reler as fontes (já com os arquivos substituídos).
    invalidateImages()
  end)
end
