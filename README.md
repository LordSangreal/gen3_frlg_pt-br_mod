# Gen 3 - Legenda PT-BR fireRed & LeafGreen

Tradução para português do Brasil dos **diálogos** de *Pokémon FireRed* e
*Pokémon LeafGreen* no formato de **mod para o gen1recomp** suporte
a Gen 3 em beta

Não é patch de ROM: o mod conversa com o motor pelo registro `text` e
sobrescreve as falas em tempo de execução. A ROM permanece intocada.

---

## Créditos

| Responsabilidade | Autor |
|---|---|
| **Tradução (a legenda)** | **BRENO** |
| **Criação do mod para o G1R** | **LordSangreal** |
| **Revisão** | **LordSangreal** e **Solid One** |

A tradução partiu do dump de storyline em português do BRENO e foi adaptada ao
formato de mod do gen1recomp por LordSangreal, com revisão de LordSangreal e
Solid One.

---

## O que está traduzido

| Catálogo | Entradas | O que é |
|---|---:|---|
| `lang/dialogue.lua` | 41 | chaves **nomeadas** do motor (`Text_*`, `PokedexRating_*`, `SafariZone_*`, `gDaycareText_*`, `CableClub_*`) — o motor usa o mesmo identificador nas duas versões, então valem para FireRed **e** LeafGreen |
| `lang/dialogue_firered.lua` | 3541 | falas próprias da ROM de FireRed (chaves `g3:<offset + 0x08000000>`) |
| `lang/dialogue_leafgreen.lua` | 3400 | falas próprias da ROM de LeafGreen (mesmas regras, offsets diferentes) |

`main.lua` detecta a versão em execução (`GameVersion.get()`) e aplica o
catálogo comum mais o específico daquela ROM.

## O que **não** está traduzido

Nomes de golpes, itens, Pokémon, cidades, menus e textos próprios do motor
continuam em inglês. Esta versão cobre apenas o que havia traduzido na fonte.

192 diálogos de LeafGreen ficaram em inglês de propósito: neles o texto da ROM
de LeafGreen é **realmente diferente** do de FireRed, e aplicar a tradução de
FireRed mostraria a frase errada. Estão listados no fim desta página.

## Formato

A chave `g3:<offset + 0x08000000>` é o offset do texto na ROM — a mesma
numeração do `<id>` do dump de storyline do PokéMMO (`id 1516117` → `0x172255`
→ `g3:08172255`). O valor usa a convenção *pret*:

| Valor | Efeito |
|---|---|
| `\n` | quebra de linha dentro da caixa |
| `\p` | nova página (espera o botão A) |
| `{PLAYER}`, `{RIVAL}`, `{STR_VAR_1..3}` | placeholders do motor |

## Acentos e o problema do tilde

O motor renderiza os acentos portugueses através de duas tabelas —
`TextIR.CHARMAP` (decode) e `FrlgFont.LATIN_GLYPHS` (render). A união das duas
cobre **`é ê á ç í ó É Á Í ô à ú Ó Ç Ê â Â Ú Ô À º ª ♂ ♀ Ë Ì`** e o resto do
latim, portanto esses caracteres aparecem **como no dump de origem**.

O que não existe em nenhuma das duas tabelas é o **tilde**: `ã`, `Ã`, `õ`, `Õ`.
Para esses o motor cai no fallback `0x00` e a letra sai **em branco** — o
próprio código do motor diz isso em `src/ui/game3/frlg_font.lua`:

> without an entry glyphId falls back to 0x00 and the letter prints blank

Deixar o tilde produziria `n o` no lugar de `não` e `POK M N` no lugar de
`POKéMON`. Por isso `ã→a`, `Ã→A`, `õ→o`, `Õ→O`. Quando alguém adicionar os
glifos de tilde ao motor, é reverter quatro substituições.

`« »` do dump viraram `" "`: a ROM guarda esses caracteres nos bytes
`0xB1`/`0xB2`, que o motor renderiza como aspas curvas — é o mesmo glifo, com
nome diferente nos dois lados.

## Instalação

Coloque a pasta em:

```
%APPDATA%\pokemon-love2d\mods\firered-legenda-ptbr\
```

e abra o jogo. O mod é carregado por padrão (não é experimental). FireRed e
LeafGreen precisam estar importados no launcher.

## Estado

Validado: sintaxe Lua, aridade de placeholder (0 divergências), escapes, e todo
caractere conferido contra o conjunto de glifos do motor. Os 3400 offsets de
LeafGreen foram verificados **por conteúdo** — decodificando a ROM em cada
offset e confirmando que o texto é o esperado, não apenas que o endereço
existe.

Ressalva honesta: a validação é de carregamento, chaves, sintaxe e glifos. A
confirmação visual em tela depende de abrir o jogo.

## Os 192 de LeafGreen que ficaram em inglês

Textos em que a ROM de LeafGreen difere da de FireRed. Exemplos:

| chave | contexto |
|---|---|
| `g3:081738c3` | fala do CAPTAIN no S.S. Anne |
| `g3:0817cc56` | Torre de Treinadores (`{02} min. {03}.{04} sec.`) |
| `g3:0817732b` | `{01} obtained HM01 from the CAPTAIN!` |
| `g3:08180727` | `{01} found a SAPPHIRE!` |
| `g3:081928a8` | fala do RIVAL |
| `g3:081955c7` | `POKéMON LEAGUE` |
| `g3:081c556d` | `{01} rubbed the CAPTAIN's back!` |

Nesses pontos o motor monta a string a partir de placeholders dinâmicos ou o
texto de LeafGreen foi redigido diferente. Cada um precisa de tradução própria
a partir da ROM de LeafGreen.

## Licença e ROM

Este repositório **não contém ROM nem dado da Nintendo**. A tradução é trabalho
autoral derivado; para usar é necessário uma ROM obtida legalmente. O texto em
ingês das tabelas é citação do jogo para fins de tradução.
