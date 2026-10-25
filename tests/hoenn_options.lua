-- luajit tests/hoenn_options.lua — options never alter battle parameters.
package.loaded['src.core.GameVersion']={get=function() return 'emerald' end}
local entry=assert(loadfile('main.lua'))()
local function registry(base)
 local changes={}
 return {changes=changes,each=function() return next,base,nil end,get=function(_,id) return base[id] end,
  override=function(_,id,v) changes[id]=v end,
  patch=function(_,id,v) changes[id]=changes[id] or {};for k,x in pairs(v) do changes[id][k]=x end end}
end
local function text(ir) local out={};for _,s in ipairs(ir) do if s.s then out[#out+1]=s.s end end;return table.concat(out) end
for _,off in ipairs({'none','nature_names','ability_names','move_names','all'}) do
 local schema={}
 local mod={content={
  text=registry({nature={{t='text',s='ADAMANT'},{t='eos'}},menu={{t='text',s='BAG'},{t='eos'}}}),
  rom_text=registry({}),strings=registry({}),
  moves=registry({TACKLE={name='TACKLE',power=35,accuracy=95,pp=35}}),
  items=registry({POTION={name='POTION',description='Heals HP',price=300}}),trainers=registry({}),
 },log={info=function() end},options={
  define=function(_,s) schema=s end,
  get=function(_,key) if off==key or off=='all' then return 'en' end;return 'pt' end,
 }}
 function mod:read(path) local f=io.open(path,'rb');if not f then return nil end;local s=f:read('*a');f:close();return s end
 entry(mod)
 assert(#schema==3)
 assert(text(mod.content.text.changes.menu)=='MOCHILA')
 assert(text(mod.content.text.changes.nature)==((off=='nature_names' or off=='all') and 'ADAMANT' or 'INFLEXÍVEL'))
 assert(mod.content.strings.changes.OVERGROW==((off=='ability_names' or off=='all') and 'OVERGROW' or 'SUPERCRESCIMENTO'))
 assert(mod.content.moves.changes.TACKLE.name==((off=='move_names' or off=='all') and 'TACKLE' or 'INVESTIDA'))
 assert(mod.content.strings.changes['No special ability.']=='Sem habilidade especial.')
 assert(mod.content.items.changes.POTION.name=='POÇÃO')
 assert(mod.content.items.changes.POTION.description:find('20 PS',1,true))
 assert(not mod.content.items.changes.POTION.description:find('\\n',1,true))
 assert(mod.content.items.changes.POTION.price==nil)
 assert(mod.content.moves.changes.TACKLE.power==nil and mod.content.moves.changes.TACKLE.pp==nil)
end
print('PASS: 3 independent language options and all-English names preserve Portuguese UI/descriptions and gameplay fields')
