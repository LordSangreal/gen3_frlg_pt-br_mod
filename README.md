# [PT-BR] Versão Brasileira — FRLG e Hoenn

Revisão local `0.2.0-local.2`: mantém os diálogos XML e acrescenta menus, botões, introdução do Birch e descrições do Emerald. As 309 descrições de itens válidos, 354 de golpes e 78 de habilidades têm tradução no catálogo.

Nas opções do mod, escolha separadamente **PORTUGUÊS / ENGLISH** para nomes de **naturezas**, **habilidades** e **golpes**. O padrão é português. As descrições continuam em português. Reabra o jogo após mudar as opções.

[Relatório desta revisão e limites de cobertura](docs/UPDATE_LOCAL2.md) · [Histórico da integração XML](docs/HOENN.md).

Somente o mod é atualizado. Nenhum commit foi criado. A integração ainda mantém em inglês textos sem correspondência segura; não há comprovação de tradução integral de todas as telas/Pokédex.

---

## Documentação anterior de FRLG

# [PT-BR] Versão Brasileira (FireRed / LeafGreen)

Tradução para português do Brasil dos **diálogos** de *Pokémon FireRed* e *Pokémon LeafGreen* no formato de **mod para o gen1recomp** suporte a Gen 3 em beta.

## Créditos

- **Breno**: Tradução original de FRLG para GBA, lançada em 2026;
- **LordSangreal**: Criação do mod, port inicial dos textos, e revisão;
- **Solid One**: Tradução, revisão, gráficos e teste;

## O que está traduzido

| Catálogo | Entradas | O que é |
|---|---:|---|
| `lang/dialogue.lua` | 4885 (41 PT-BR) | chaves **nomeadas** do motor — 41 já traduzidas e 4844 importadas da referência espanhola, pendentes de tradução; o motor usa o mesmo identificador nas duas versões, então valem para FireRed **e** LeafGreen |
| `lang/dialogue_firered.lua` | 3541 | falas próprias da ROM de FireRed (chaves `g3:<offset + 0x08000000>`) |
| `lang/dialogue_leafgreen.lua` | 3400 | falas próprias da ROM de LeafGreen (mesmas regras, offsets diferentes) |

Há outros arquivos .lua, porém foram importados direto da localização oficial espanhol gerada via [gen1recomp-translation-mod-generator](https://github.com/thibautbus/gen1recomp-translation-mod-generator). Elas foram mantidas no formato de segmentos de texto do motor para preservar quebras, pausas e placeholders. Estão no repositório de forma provisória, sendo substituídos por textos em PT-BR posteriormente.

## Instalação

Coloque a pasta em:

```
%APPDATA%\pokemon-love2d\mods\gen3_frlg_pt-br_mod\
```

e abra o jogo. O mod é carregado por padrão (não é experimental). FireRed e LeafGreen precisam estar importados no launcher.