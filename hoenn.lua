-- Hoenn uses only the content API. No engine/cache/font replacements.
local TAG = {
  ['{POKEBLOCK}'] = 'POKéBLOCK', ['{PKMN}'] = 'POKéMON',
  ['{UP_ARROW}'] = '↑', ['{DOWN_ARROW}'] = '↓',
  ['{LEFT_ARROW}'] = '←', ['{RIGHT_ARROW}'] = '→',
}
local PH = { player = 1, strvar1 = 2, strvar2 = 3, strvar3 = 4, rival = 6 }
local function normalize(s)
  return (s:gsub('…', '...'):gsub('«', '"'):gsub('»', '"')
    :gsub('“', '"'):gsub('”', '"'):gsub('’', "'"):gsub('‘', "'"):gsub('¥', '$')
    :gsub('%s+', ' '):gsub('^ ', ''):gsub(' $', ''))
end

-- Retain the cart's placeholder objects and reject control codes the XML
-- cannot describe, rather than removing a sound, pause, font or battle code.
local function sourceText(ir)
  if type(ir) == 'string' then return ir, {} end
  if type(ir) ~= 'table' then return nil end
  local out, placeholders, controls = {}, {}, { prefix = {}, suffix = {} }
  for index, segment in ipairs(ir) do
    local t = segment.t
    local code = PH[t] or (t == 'strvar' and segment.n and segment.n + 1)
      or (t == 'ph' and segment.code)
    if t == 'text' then out[#out + 1] = segment.s
    elseif t == 'tag' and TAG[segment.tag] then out[#out + 1] = TAG[segment.tag]
    elseif t == 'nl' or t == 'para' or t == 'scroll' then out[#out + 1] = ' '
    elseif code and code >= 1 and code <= 6 then
      out[#out + 1] = ('{%02d}'):format(code)
      placeholders[code] = segment
    elseif t == 'ext' then
      if #out == 0 then controls.prefix[#controls.prefix + 1] = segment
      else
        for i = index + 1, #ir do
          if ir[i].t ~= 'ext' and ir[i].t ~= 'eos' then return nil end
        end
        controls.suffix[#controls.suffix + 1] = segment
      end
    elseif t ~= 'eos' then return nil end
  end
  return table.concat(out), placeholders, controls
end

local function translatedIR(text, placeholders, controls)
  local out, cursor = {}, 1
  local function copyControl(segment)
    local copy = {}
    for k,v in pairs(segment) do copy[k] = v end
    out[#out + 1] = copy
  end
  for _, segment in ipairs(controls and controls.prefix or {}) do copyControl(segment) end
  text = text:gsub('\\n', '\n')
  while cursor <= #text do
    local a, b, token = text:find('({%d%d})', cursor)
    local n = text:find('\n', cursor, true)
    if n and (not a or n < a) then
      if n > cursor then out[#out + 1] = { t = 'text', s = text:sub(cursor, n - 1) } end
      local last = n
      while text:sub(last + 1, last + 1) == '\n' do last = last + 1 end
      out[#out + 1] = { t = last > n and 'para' or 'nl' }
      cursor = last + 1
    elseif a then
      if a > cursor then out[#out + 1] = { t = 'text', s = text:sub(cursor, a - 1) } end
      local source = placeholders[tonumber(token:sub(2, 3))]
      if not source then return nil end
      local copy = {}
      for k, v in pairs(source) do copy[k] = v end
      out[#out + 1] = copy
      cursor = b + 1
    else
      out[#out + 1] = { t = 'text', s = text:sub(cursor) }
      break
    end
  end
  for _, segment in ipairs(controls and controls.suffix or {}) do copyControl(segment) end
  out[#out + 1] = { t = 'eos' }
  return out
end

return function(mod, game)
  if game ~= 'emerald' and game ~= 'ruby' and game ~= 'sapphire' then return end
  local function catalog(path)
    local body = mod:read(path)
    return body and assert(loadstring(body, '@' .. path))() or {}
  end
  local schema = catalog('options.lua')
  if mod.options then mod.options:define(schema) end
  local function namesInPortuguese(category)
    return not mod.options or mod.options:get(category) ~= 'en'
  end
  local uiStrings = catalog('lang/hoenn/ui_strings.lua')
  local names = catalog('lang/hoenn/names.lua')
  local uiNormalized, categories = {}, {}
  for english, target in pairs(uiStrings) do uiNormalized[normalize(english)] = target end
  for category, values in pairs(names) do
    for english, target in pairs(values) do
      categories[normalize(english)] = { category = category, english = english, target = target }
    end
  end
  local byAddress, byEnglish, ambiguous = {}, {}, {}
  local function addRows(rows)
    for _, row in ipairs(rows) do
      row[4] = normalize(row[2]:gsub('\\n', ' '))
      byAddress[row[1]] = row
      local previous = byEnglish[row[4]]
      if previous and previous[3] ~= row[3] then ambiguous[row[4]] = true end
      byEnglish[row[4]] = row
    end
  end
  local part = 1
  while true do
    local path = 'lang/hoenn/catalog_' .. part .. '.lua'
    local body = mod:read(path)
    if not body then break end
    local rows = assert(loadstring(body, '@' .. path))()
    addRows(rows)
    part = part + 1
  end
  assert(part > 1, 'Hoenn translation catalogs are missing')
  local ui = mod:read('lang/hoenn/ui.lua')
  if ui then addRows(assert(loadstring(ui, '@lang/hoenn/ui.lua'))()) end
  local counts = { dialogue = 0, strings = 0, records = 0, unsupported = 0, matched_xml_ids = 0 }
  local usedRows = {}
  local function match(source, key)
    local normalized = normalize(source)
    local name = categories[normalized]
    if name then
      return { key or ('name:' .. normalized), source, namesInPortuguese(name.category) and name.target or name.english }
    end
    local row = game == 'emerald' and byAddress[key]
    if row and row[4] == normalized then return row end
    if not ambiguous[normalized] and byEnglish[normalized] then return byEnglish[normalized] end
    if uiNormalized[normalized] then return { key or ('ui:' .. normalized), source, uiNormalized[normalized] } end
  end
  -- All aliases/offsets come from the currently loaded ROM. Never install
  -- Emerald addresses in Ruby/Sapphire; their revisions have different layouts.
  local textSource = mod.content.text
  local firstKey
  for key in textSource:each() do firstKey = key; break end
  if firstKey == nil and mod.datasets and mod.datasets.open then
    local view = mod.datasets:open(game)
    if view and view.content then textSource = view.content.text end
  end
  for key, original in textSource:each() do
    local source, placeholders, controls = sourceText(original)
    if source then
      local row = match(source, key)
      if row then
        local ir = translatedIR(row[3], placeholders, controls)
        if ir then
          mod.content.text:override(key, ir)
          -- Native menus/intro resolve through RomText before script text.
          if mod.content.rom_text then mod.content.rom_text:override(key, ir) end
          counts.dialogue = counts.dialogue + 1
          usedRows[row[1]] = true
        end
      end
    else counts.unsupported = counts.unsupported + 1 end
  end
  local function translatePlain(source)
    if type(source) ~= 'string' then return nil end
    local row = match(source)
    -- String/record APIs do not expand script placeholders.
    if row and not row[3]:find('{%d%d}') then return row[3]:gsub('\\n', '\n') end
  end
  for english, target in pairs(uiStrings) do
    local name = categories[normalize(english)]
    if name then target = namesInPortuguese(name.category) and name.target or name.english end
    mod.content.strings:override(english, target)
    counts.strings = counts.strings + 1
  end
  for _, values in pairs(names) do
    for english in pairs(values) do
      local name = categories[normalize(english)]
      mod.content.strings:override(english, namesInPortuguese(name.category) and name.target or name.english)
    end
  end
  for key, original in mod.content.strings:each() do
    local value = translatePlain(original)
    if value then mod.content.strings:override(key, value); counts.strings = counts.strings + 1 end
  end
  for _, spec in ipairs({
    { 'items', 'name', 'description' }, { 'moves', 'name', 'description' },
    { 'trainers', 'name', 'className' },
  }) do
    local registry = mod.content[spec[1]]
    for key, original in registry:each() do
      if type(original) == 'table' then
        local patch = {}
        for i = 2, #spec do
          local field = spec[i]
          patch[field] = translatePlain(original[field])
        end
        if next(patch) then registry:patch(key, patch); counts.records = counts.records + 1 end
      end
    end
  end
  local function cleanBreaks(value)
    return (value:gsub('\\\\n', '\n'):gsub('\\n', '\n'))
  end
  for _, spec in ipairs({
    { 'item_names', 'items', 'name' }, { 'item_descriptions', 'items', 'description' },
  }) do
    local registry = mod.content[spec[2]]
    for id, value in pairs(catalog('lang/' .. spec[1] .. '.lua')) do
      -- Only patch semantic IDs that exist in the active game's registry.
      if registry.get and registry:get(id) and type(value) == 'string' then
        registry:patch(id, { [spec[3]] = cleanBreaks(value) })
        counts.records = counts.records + 1
      end
    end
  end
  mod.exports = mod.exports or {}
  mod.exports.hoenn = counts
  for key in pairs(usedRows) do
    if key:match('^g3:') then counts.matched_xml_ids = counts.matched_xml_ids + 1 end
  end
  mod.log:info('Hoenn PT-BR [%s]: %d textos, %d strings, %d registros; %d textos com controles preservados sem traducao',
    game, counts.dialogue, counts.strings, counts.records, counts.unsupported)
  return counts
end
