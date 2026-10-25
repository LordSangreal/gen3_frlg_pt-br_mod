-- Run from the mod root: luajit tests/hoenn.lua [Emerald scripts/text.lua]
local entry = assert(loadfile('main.lua'))()
local function registry(base)
  local changes = {}
  return {
    changes = changes,
    each = function() return next, base, nil end,
    override = function(_, id, value) changes[id] = value end,
    patch = function(_, id, value) changes[id] = value end,
  }
end
local function modFor(game, texts, strings, catalogs)
  package.loaded['src.core.GameVersion'] = { get = function() return game end }
  local mod = { content = {
    text = registry(texts or {}), strings = registry(strings or {}),
    items = registry({}), moves = registry({}), trainers = registry({}),
  }, log = { info = function() end }, reads = {} }
  function mod:read(path)
    self.reads[#self.reads + 1] = path
    if catalogs and path:find('lang/hoenn/', 1, true) then
      return path == 'lang/hoenn/catalog_1.lua' and catalogs or nil
    end
    local f = io.open(path, 'rb')
    if not f then return nil end
    local s = f:read('*a'); f:close(); return s
  end
  return mod
end
local function plain(ir)
  local out = {}
  for _, s in ipairs(ir) do
    if s.t == 'text' then out[#out + 1] = s.s end
  end
  return table.concat(out)
end
local function count(t) local n = 0; for _ in pairs(t) do n = n + 1 end; return n end
local rows = [[return {
  {'g3:08000001', 'Hello {01}!\\nWelcome!', 'Olá {01}!\\nBem-vindo!'},
  {'g3:08000002', 'Same source', 'Primeiro'},
  {'g3:08000003', 'Same source', 'Segundo'},
  {'g3:08000004', 'Safe text', 'Texto seguro'},
  {'g3:08000005', 'Item', 'Objeto'},
  {'g3:08000006', 'Used {02}!', 'Usou {02}!'},
  {'g3:08000007', 'POKéBLOCK costs $50.', 'POKéBLOCO custa $50.'},
}]]
for _, game in ipairs({'emerald', 'ruby', 'sapphire'}) do
  local ir = {{t='text',s='Hello '},{t='player'},{t='text',s='!'},{t='scroll'},{t='text',s='Welcome!'},{t='eos'}}
  local mod = modFor(game, {
    ['edition_alias'] = ir,
    strvar = {{t='text',s='Used '},{t='strvar',n=1},{t='text',s='!'},{t='eos'}},
    tag = {{t='tag',tag='{POKEBLOCK}'},{t='text',s=' costs ¥50.'},{t='eos'}},
    ['g3:08000001'] = {{t='text',s='Different cart text'},{t='eos'}},
    ambiguous = {{t='text',s='Same source'},{t='eos'}},
    controlled = {{t='text',s='Safe text'},{t='wait',frames=40},{t='eos'}},
    ['g3:08000002'] = {{t='text',s='Same source'},{t='eos'}},
  }, { menu = 'Safe text', unknown = 'Untranslated' }, rows)
  mod.content.items = registry({POTION={name='Item',price=300}})
  entry(mod)
  assert(plain(mod.content.text.changes.edition_alias) == 'Olá !Bem-vindo!')
  assert(mod.content.text.changes.edition_alias[2].t == 'player')
  assert(mod.content.text.changes.strvar[2].t == 'strvar')
  assert(mod.content.text.changes.strvar[2].n == 1)
  assert(plain(mod.content.text.changes.tag) == 'POKéBLOCO custa $50.')
  assert(not mod.content.text.changes['g3:08000001'], 'must verify address against English')
  assert(not mod.content.text.changes.ambiguous, 'ambiguous English must remain unchanged')
  assert(not mod.content.text.changes.controlled, 'must preserve unsupported controls')
  assert((mod.content.text.changes['g3:08000002'] ~= nil) == (game == 'emerald'))
  assert(mod.content.strings.changes.menu == 'Texto seguro')
  assert(not mod.content.strings.changes.unknown)
  assert(mod.content.items.changes.POTION.name == 'Objeto')
  assert(mod.content.items.changes.POTION.price == nil)
end
for _, game in ipairs({'red', 'crystal', false}) do
  local mod = modFor(game)
  entry(mod)
  assert(#mod.reads == 0, 'unsupported games must do nothing')
end
-- Real XML example: preserve the original KUN/player placeholder objects.
local mod = modFor('emerald', {
  ['g3:081de8a0'] = {{t='player'}, {t='ph',code=5,name='KUN'}, {t='text',s='!'}, {t='nl'}, {t='text',s='Please, come with me!'}, {t='eos'}},
})
entry(mod)
assert(mod.content.text.changes['g3:081de8a0'])
assert(mod.content.text.changes['g3:081de8a0'][2].code == 5)
print('PASS: routing, address guards, RS offsets, ambiguity, placeholders, control safety and record patches')
if arg[1] then
  local base = assert(loadfile(arg[1]))()
  for _, game in ipairs({'emerald', 'ruby', 'sapphire'}) do
    -- Only Emerald is a real cache. RS reuse here checks routing over the
    -- same text corpus, NOT coverage of a Ruby/Sapphire cartridge.
    local mod = modFor(game, base)
    local stats = entry(mod)
    assert(stats.dialogue > 1000)
    for _, ir in pairs(mod.content.text.changes) do
      assert(ir[#ir].t == 'eos')
      for _, segment in ipairs(ir) do
        if segment.t == 'text' then assert(not segment.s:find('{%d%d}')) end
      end
    end
    print(('CORPUS %s: %d/%d text keys translated; unsupported controls: %d'):format(game, count(mod.content.text.changes), count(base), stats.unsupported))
    print(('  Distinct XML rows used: %d/6158'):format(stats.matched_xml_ids))
  end
end
