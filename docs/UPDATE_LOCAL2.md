# Revisão 0.2.0-local.2 — interface e descrições do Emerald

A revisão anterior aplicava o XML de diálogos, mas não carregava os catálogos próprios de interface e descrições. A confirmação do usuário mostrou que os diálogos estavam traduzidos. O problema não era o carregamento do mod inteiro.

## Alterações

- Reaproveitamento dos catálogos PT-BR já existentes no repositório para nomes de itens, descrições, nomes de golpes, habilidades e textos comuns. Os arquivos legados não foram alterados.
- 2.461 correspondências de interface/descrições no catálogo complementar, incluindo textos novos para comandos, bolsa, salvar, seleção de Pokémon e botões.
- Complemento nomeado para a introdução do Professor Birch.
- Aplicação nas APIs `text` e `rom_text`, para atender tanto os diálogos de scripts quanto as telas nativas do Emerald.
- Descrições de golpes relacionadas por identificador semântico entre os catálogos FRLG e Emerald. Não há tradução por aproximação de frases.
- Opções independentes para nomes de naturezas, habilidades e golpes: **PORTUGUÊS / ENGLISH**, com português por padrão. Descrições permanecem em português.
- Leitura alternativa do dataset apenas se o registro de textos estiver vazio. Controles IR no início/fim são preservados; controles internos não suportados continuam sem substituição.
- Nenhum hook, substituição de função do motor ou escrita em cache/ROM/save.

## Configuração

Abra as opções do mod **[PT-BR] Versão Brasileira (FRLG / Hoenn)** no gerenciador de mods. Há três linhas: **NOMES DAS NATUREZAS**, **NOMES DAS HABILIDADES** e **NOMES DOS GOLPES**. Escolha `ENGLISH` nas categorias desejadas e reabra o jogo para aplicar. As opções foram implementadas no caminho de Hoenn; o comportamento legado de FRLG foi preservado.

## Verificação

Testes com os módulos do `game.love` extraído do AppImage efetivamente usado, `gen1recomp-0.3.93-linux-x86_64.AppImage`, em ambiente isolado e com sistema de arquivos em memória:

- Carregamento e merge sem erros; `MOCHILA`, `SALVAR` e a introdução de Birch em português.
- 309 de 309 descrições de itens válidos de Emerald traduzidas; itens vazios/reservados não entram nessa contagem.
- Catálogo das 354 descrições de golpes e 78 descrições de habilidades coberto, incluindo a entrada sem habilidade.
- 25 nomes de naturezas, 77 nomes de habilidades e 354 nomes de golpes com opção de idioma.
- Testes de cada opção separada e todas em inglês. Exemplos: `ADAMANT`, `OVERGROW` e `TACKLE`, mantendo menus e descrições em português.
- Campos de gameplay, como preço, poder, precisão e PP, não são modificados.
- No corpus de diálogos do cache: 8.688 de 15.656 chaves recebem substituições, incluindo aliases e novos textos de interface. O total de chaves não é uma contagem de falas únicas.
- O usuário confirmou que os diálogos da revisão anterior funcionavam. A validação visual dos novos textos depende de reabrir o jogo.

Ainda há textos fora dos catálogos e controles dinâmicos sem correspondência segura. Esta revisão amplia a tradução; não constitui comprovação de tradução de 100% do jogo, de todas as entradas da Pokédex ou de todo conteúdo de outros mods. Ruby/Sapphire permanecem sem medição de cobertura em suas ROMs.

## Instalação e preservação

Esta revisão substitui somente os arquivos de `mods/gen3_frlg_pt-br_mod`. A instalação anterior é copiada para um ZIP de backup antes da substituição. Motor, configurações, saves e outros mods não são alterados. Nenhum commit ou envio ao GitHub foi realizado.
