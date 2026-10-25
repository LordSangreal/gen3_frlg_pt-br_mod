-- Run from mod root: luajit tools/build_hoenn_ui.lua EMERALD_TEXT FRLG_DESCRIPTIONS EMERALD_DESCRIPTIONS
local function load(path) return assert(loadfile(path))() end
local base = load(assert(arg[1], 'Emerald scripts/text.lua is required'))
local fr, em = load(assert(arg[2])), load(assert(arg[3]))
local function normalize(s) return (s:gsub('\\n',' '):gsub('%s+',' '):gsub('^ ',''):gsub(' $','')) end
local translated, normalized = {}, {}
for _,name in ipairs({'strings','strings_by_english'}) do
 for en,pt in pairs(load('lang/'..name..'.lua')) do
  translated[en]=pt
  normalized[normalize(en)]=pt
 end
end
for group,rows in pairs(em) do
 for key,source in pairs(rows) do
  local original=fr[group] and fr[group][key]
  local target=original and normalized[normalize(original)]
  if target then translated[source]=target end
 end
end
-- General controls, menus and common screen labels outside the XML.
local extra = {
 ['MAGMA EMBLEM']='EMBLEMA MAGMA', ['OLD SEA MAP']='MAPA MARÍTIMO ANTIGO',
 ['{POKEBLOCK} CASE']='CAIXA DE POKéBLOCOS',
 ['A faded sea chart\nthat shows the way\nto a certain island.']='Um mapa marítimo antigo\nque mostra o caminho\npara uma certa ilha.',
 ["A medal-like item in\nthe same shape as\nTEAM MAGMA's mark."]='Uma medalha com\no mesmo formato do\nsímbolo da EQUIPE MAGMA.',
 ['A case for holding\n{POKEBLOCK}S made with\na BERRY BLENDER.']='Uma caixa para guardar\nPOKéBLOCOS feitos no\nMISTURADOR DE FRUTAS.',

 ['BAG']='MOCHILA', ['SAVE']='SALVAR', ['OPTION']='OPÇÕES', ['OPTIONS']='OPÇÕES', ['EXIT']='SAIR',
 ['CONTINUE']='CONTINUAR', ['NEW GAME']='NOVO JOGO', ['MYSTERY GIFT']='PRESENTE MISTERIOSO',
 ['CANCEL']='CANCELAR', ['YES']='SIM', ['NO']='NÃO', ['CLOSE']='FECHAR', ['BACK']='VOLTAR',
 ['REST']='DESCANSAR', ['RETIRE']='DESISTIR', ['SUMMARY']='RESUMO', ['SWITCH']='TROCAR',
 ['ITEM']='ITEM', ['ITEMS']='ITENS', ['KEY ITEMS']='ITENS IMPORTANTES', ['POKé BALLS']='POKé BOLAS',
 ['BERRIES']='FRUTAS', ['USE']='USAR', ['GIVE']='DAR', ['TOSS']='JOGAR FORA', ['REGISTER']='REGISTRAR',
 ['DESELECT']='DESMARCAR', ['CHECK']='VERIFICAR', ['READ']='LER', ['TAKE']='PEGAR', ['QUIT']='SAIR',
 ['CHOOSE']='ESCOLHER', ['SELECT']='SELECIONAR', ['MOVE']='MOVER', ['DEPOSIT']='DEPOSITAR', ['WITHDRAW']='RETIRAR',
 ['RELEASE']='LIBERAR', ['MARK']='MARCAR', ['PARTY POKéMON']='EQUIPE POKéMON', ['MOVE POKéMON']='MOVER POKéMON',
 ['DEPOSIT POKéMON']='DEPOSITAR POKéMON', ['WITHDRAW POKéMON']='RETIRAR POKéMON',
 ['MOVE ITEMS']='MOVER ITENS', ['SEE YA!']='ATÉ MAIS!', ['POKéMON LIST']='LISTA DE POKéMON',
 ['FIGHT']='LUTAR', ['RUN']='FUGIR', ['ATTACK']='ATAQUE', ['DEFENSE']='DEFESA', ['SPEED']='VELOCIDADE',
 ['SP. ATK']='ATQ. ESP.', ['SP. DEF']='DEF. ESP.', ['SP.ATK']='ATQ.ESP.', ['SP.DEF']='DEF.ESP.',
 ['ACCURACY']='PRECISÃO', ['POWER']='PODER', ['TYPE']='TIPO', ['ABILITY']='HABILIDADE', ['EXP. POINTS']='PONTOS EXP.',
 ['NEXT LV.']='PRÓX. NÍVEL', ['LEVEL']='NÍVEL', ['STATUS']='ESTADO', ['NORMAL']='NORMAL',
 ['FIRE']='FOGO', ['WATER']='ÁGUA', ['GRASS']='GRAMA', ['ELECTRIC']='ELÉTRICO', ['ICE']='GELO',
 ['FIGHTING']='LUTADOR', ['POISON']='VENENO', ['GROUND']='TERRA', ['FLYING']='VOADOR', ['PSYCHIC']='PSÍQUICO',
 ['BUG']='INSETO', ['ROCK']='PEDRA', ['GHOST']='FANTASMA', ['DRAGON']='DRAGÃO', ['DARK']='SOMBRIO', ['STEEL']='AÇO',
 ['TEXT SPEED']='VEL. DO TEXTO', ['BATTLE SCENE']='ANIM. DE BATALHA', ['BATTLE STYLE']='ESTILO DE BATALHA',
 ['SOUND']='SOM', ['BUTTON MODE']='MODO DOS BOTÕES', ['FRAME']='MOLDURA', ['SLOW']='LENTO', ['MID']='MÉDIO',
 ['FAST']='RÁPIDO', ['ON']='LIGADO', ['OFF']='DESLIGADO', ['SHIFT']='TROCAR', ['SET']='FIXO',
 ['MONO']='MONO', ['STEREO']='ESTÉREO', ['HELP']='AJUDA', ['MONEY']='DINHEIRO', ['PLAYER']='JOGADOR',
 ['TIME']='TEMPO', ['BADGES']='INSÍGNIAS', ['NAME']='NOME', ['BOY']='MENINO', ['GIRL']='MENINA',
 ['COOL']='ESTILO', ['BEAUTY']='BELEZA', ['CUTE']='FOFURA', ['SMART']='INTELIGÊNCIA', ['TOUGH']='FIRMEZA',
 ['APPEAL']='APELO', ['JAM']='DISTRAÇÃO', ['RIBBONS']='FITAS', ['NONE']='NENHUM', ['OT']='TO',
 ['POKéMON INFO']='INFORMAÇÕES', ['POKéMON SKILLS']='ATRIBUTOS', ['BATTLE MOVES']='GOLPES DE BATALHA',
 ['CONTEST MOVES']='GOLPES DE CONCURSO', ['TRAINER MEMO']='NOTAS DO TREINADOR',
 ['RETURN TO MAIN\nMENU?']='VOLTAR AO MENU\nPRINCIPAL?', ['Are you a boy?\nOr are you a girl?']='Você é um menino?\nOu é uma menina?',
}
for en,pt in pairs(extra) do translated[en]=pt end
for en,pt in pairs(load('tools/hoenn_ui_corrections.lua')) do translated[en]=pt end
local natures = {HARDY='FIRME',LONELY='SOLITÁRIA',BRAVE='VALENTE',ADAMANT='INFLEXÍVEL',NAUGHTY='TRAVESSA',
 BOLD='OUSADA',DOCILE='DÓCIL',RELAXED='DESCONTRAÍDA',IMPISH='ESPERTA',LAX='RELAXADA',TIMID='TÍMIDA',
 HASTY='APRESSADA',SERIOUS='SÉRIA',JOLLY='ALEGRE',NAIVE='INGÊNUA',MODEST='MODESTA',MILD='AMÁVEL',
 QUIET='QUIETA',BASHFUL='ACANHADA',RASH='IMPRUDENTE',CALM='CALMA',GENTLE='GENTIL',SASSY='ATREVIDA',
 CAREFUL='CUIDADOSA',QUIRKY='EXCÊNTRICA'}
for en,pt in pairs(natures) do translated[en]=pt end
local function quote(s) return string.format('%q',s) end
local out=assert(io.open('lang/hoenn/ui_strings.lua','w'))
out:write('-- Generated by tools/build_hoenn_ui.lua from the existing PT-BR catalogs.\nreturn {\n')
local keys={};for k in pairs(translated) do keys[#keys+1]=k end;table.sort(keys)
for _,k in ipairs(keys) do out:write('  [',quote(k),'] = ',quote(translated[k]),',\n') end
out:write('}\n');out:close()
local explicit={
 gText_Birch_Welcome='Olá! Desculpe pela espera!\\n\\nBem-vindo ao mundo dos POKéMON!\\n\\nMeu nome é BIRCH.\\n\\nMas todos me chamam de\\nPROFESSOR POKéMON.',
 gText_Birch_MainSpeech='Este mundo é habitado por criaturas\\nconhecidas como POKéMON.\\n\\nNós, humanos, vivemos ao lado deles,\\ncomo amigos e companheiros de trabalho.\\n\\nÀs vezes, também nos unimos\\npara batalhar com outras pessoas.\\n\\nApesar de sermos tão próximos,\\nainda não sabemos tudo sobre eles.\\n\\nHá muitos segredos\\nenvolvendo os POKéMON.\\n\\nEu faço pesquisas para desvendar\\nos mistérios dos POKéMON.\\nÉ esse o meu trabalho.',
 gText_Birch_Pokemon='Isto é o que chamamos de “POKéMON”.',
 gText_Birch_AndYouAre='E você é?',
 gText_Birch_BoyOrGirl='Você é um menino?\\nOu é uma menina?',
 gText_Birch_WhatsYourName='Muito bem.\\nQual é o seu nome?',
 gText_Birch_SoItsPlayer='Então é {01}{05}?',
 gText_Birch_YourePlayer='Ah, entendi!\\n\\nVocê é {01}{05}, que está se mudando\\npara minha cidade, LITTLEROOT.\\nAgora entendi!',
 gText_Birch_AreYouReady='Muito bem, está tudo pronto?\\n\\nSua própria aventura\\nestá prestes a começar.\\n\\nTenha coragem e entre no mundo\\ndos POKéMON, onde sonhos, aventuras\\ne amizades esperam por você!\\n\\nEstarei esperando sua visita.\\nVenha ao meu LABORATÓRIO POKéMON.',
 gText_BirchInTrouble='O PROF. BIRCH está em apuros!\\nLiberte um POKéMON para salvá-lo!',
}
-- Derive English from the actual named IR; retain numeric placeholders.
local function plain(ir)
 local out={}
 for _,s in ipairs(ir) do
  if s.t=='text' then out[#out+1]=s.s
  elseif s.t=='nl' or s.t=='para' or s.t=='scroll' then out[#out+1]=' '
  elseif s.t=='player' then out[#out+1]='{01}'
  elseif s.t=='ph' then out[#out+1]=('{%02d}'):format(s.code)
  elseif s.t~='eos' then error('unsupported supplemental IR: '..s.t) end
 end
 return table.concat(out)
end
out=assert(io.open('lang/hoenn/ui.lua','w'));out:write('-- Named Hoenn introduction supplements.\nreturn {\n')
keys={};for k in pairs(explicit) do keys[#keys+1]=k end;table.sort(keys)
for _,k in ipairs(keys) do out:write('  {',quote(k),', ',quote(plain(assert(base[k],k))),', ',quote(explicit[k]),'},\n') end
out:write('}\n');out:close()
print('UI/description string mappings:',#(function() local a={};for k in pairs(translated) do a[#a+1]=k end;return a end)())

local names={nature_names=natures,ability_names={},move_names={}}
local englishMove=load(arg[1]:gsub('/scripts/text.lua$','/pokemon/move_names.lua'))
local englishAbility=load(arg[1]:gsub('/scripts/text.lua$','/pokemon/ability_names.lua'))
local moves=load('lang/move_names.lua')
moves.SURF='SURFAR';moves.AMNESIA='AMNÉSIA';moves.TRANSFORM='TRANSFORMAR';moves.GRASSWHISTLE='ASSOBIO DE GRAMA'
for _,en in pairs(englishMove) do
 local key=en:upper():gsub('[%s%-]+','_'):gsub('[^%w_]','')
 if moves[key] then names.move_names[en]=moves[key] end
end
for _,en in pairs(englishAbility) do
 if translated[en] then names.ability_names[en]=translated[en] end
end
out=assert(io.open('lang/hoenn/names.lua','w'));out:write('-- Generated category-specific name translations.\nreturn {\n')
for _,category in ipairs({'nature_names','ability_names','move_names'}) do
 out:write('  ',category,' = {\n');keys={};for k in pairs(names[category]) do keys[#keys+1]=k end;table.sort(keys)
 for _,k in ipairs(keys) do out:write('    [',quote(k),'] = ',quote(names[category][k]),',\n') end
 out:write('  },\n');print(category,#keys)
end
out:write('}\n');out:close()
