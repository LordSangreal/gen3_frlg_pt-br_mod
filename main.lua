-- firered-legenda-ptbr: traducao PT-BR dos dialogos da ROM de FireRed.
--
-- Formato do catalogo (mesmo da referencia espanhola, para que LeafGreen
-- entre depois sem reescrever nada):
--
--   lang/dialogue.lua          chaves NOMEADAS -- o motor usa o mesmo
--                               identificador em FireRed e LeafGreen, entao
--                               este catalogo e seguro nos dois jogos.
--   lang/dialogue_firered.lua  chaves g3:<offset + 0x08000000> -- offset do
--                               texto na ROM de FireRed. O MESMO offset em
--                               LeafGreen aponta para outro texto (ou para
--                               nada), por isso este arquivo so se aplica em
--                               FireRed.
--   lang/dialogue_leafgreen.lua  idem para LeafGreen. Criado quando houver a
--                               ROM; enquanto nao existir, o motor aplica
--                               apenas o comum em LeafGreen.
--
-- Chave g3:<offset + 0x08000000>: o offset do texto na ROM, que e a mesma
-- numeracao do <id> do dump de storyline do PokeMMO (id 1516117 -> 0x172255
-- -> g3:08172255).
--
-- Codigos de controle do valor:
--   \n   quebra de linha dentro da caixa
--   \p   nova pagina (espera o botao A)
--   {PLAYER} {RIVAL} {STR_VAR_1..3}  placeholders
--
-- Fora do escopo desta versao: golpes, itens, nomes e textos de menu, que
-- continuam em ingles. Os caracteres ã/Ã/õ/Õ nao tem glifo na latin_small da
-- ROM (slots 0x0A/0x18/0x1F sao byte-identicos ao slot vazio), por isso
-- aparecem degradados para a/A.
return function(mod)
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

  local counts = { comum = 0, propria = 0 }
  local function applyDialogue(name, bucket)
    for key, value in pairs(catalog(name)) do
      if type(key) == "string" and type(value) == "string" and value ~= "" then
        mod.content.text:override(key, value)
        counts[bucket] = counts[bucket] + 1
      end
    end
  end

  -- comum as duas versoes: chaves nomeadas do motor
  applyDialogue("dialogue", "comum")

  -- proprio de cada ROM: chaves g3:, que sao offsets diferentes em cada jogo
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

  mod.events:on("game.ready", function()
    mod.log:info("FireRed Legenda PT-BR [%s]: %d comuns + %d proprios",
      vid, counts.comum, counts.propria)
  end)
end
