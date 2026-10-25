> Histórico da revisão local.1. Para a versão atual instalada, veja [UPDATE_LOCAL2.md](UPDATE_LOCAL2.md).

# Integração PT-BR de Hoenn — 0.2.0-local.1

## Resultado

A detecção usa `src.core.GameVersion.get()`. Emerald, Ruby e Sapphire são encaminhados para `hoenn.lua` antes de carregar qualquer catálogo, fonte ou hook de FRLG. FireRed e LeafGreen continuam usando a implementação anterior. Jogos desconhecidos não recebem alterações.

O módulo Hoenn só escreve nas APIs de conteúdo pertencentes ao mod: textos, strings e campos de nomes/descrições encontrados. Não grava no motor, ROM, cache, configurações ou saves; não instala hooks nem substitui funções do motor. As contribuições são administradas pelo carregador de mods e podem ser removidas por ele.

## Fontes e correspondências

- Repositório base: https://github.com/LordSangreal/gen3_frlg_pt-br_mod — base `e16d05b`.
- Release FRLG preservada separadamente: `v0.1.4`, baixada do repositório original.
- XML inglês: `dump_BPE_en(1).xml`, 6.158 IDs.
- XML PT-BR: `dump_BPE_pt-BR_zambrakas(1).xml`, 6.123 IDs, crédito indicado no nome: **zambrakas**.
- ZIP espanhol consultado: `translation-es-gen3-rse-0.10.1.zip`. Serviu para confirmar organização, APIs, formatos IR e diferenças entre revisões de Ruby/Sapphire. Seus catálogos espanhóis não são carregados em Hoenn.
- Motor local consultado em modo de leitura: distribuição `0.3.93`, `game.love` e cache inglês de Emerald. Nenhum arquivo deles foi modificado.

Os XMLs são unidos pelo ID numérico. O ID `0x10000000 + offset` do PokéMMO corresponde ao ponteiro GBA `0x08000000 + offset`, convertido para `g3:xxxxxxxx`. Exemplo: `270387329` → `g3:081dc881`.

Mesmo em Emerald, o texto inglês da ROM precisa coincidir com o inglês do XML. Em Ruby/Sapphire, os endereços de Emerald nunca são reutilizados: o módulo percorre as chaves da ROM carregada e aceita apenas correspondências inglesas sem traduções conflitantes. Assim, não depende do layout de endereços de uma revisão específica. Diferenças reais entre as histórias permanecem em inglês.

A comparação normaliza espaços/quebras, aspas tipográficas, reticências e o símbolo monetário `¥`/`$`. Mantém maiúsculas, palavras, números e variáveis. Variáveis `PLAYER`, `STR_VAR`, `RIVAL` e `KUN` usam os objetos IR originais; não são substituídas por nomes fixos. Setas e as marcas estáticas POKéMON/POKéBLOCK são reconhecidas. Controles que não podem ser representados pelo XML são preservados deixando o texto original.

## Correções do material de entrada

`tools/hoenn_corrections.json` contém 77 complementos auditáveis, sem editar os XMLs:

- 35 traduções novas para entradas ausentes, incluindo a introdução, a mãe e o Centro Pokémon.
- 42 reparos de variáveis ou substituição de falas incompatíveis com o ID inglês. Exemplos: apresentação de MAY contendo fala de BRENDAN, mensagem de SURF com uma fala sobre porta, mensagem de DIVE contendo uma descrição da superfície.

Após os complementos, as 6.158 entradas inglesas são elegíveis; nenhuma é descartada pelo gerador. Isso é cobertura do XML, não uma afirmação de tradução de 100% da interface/jogo. O texto PT original pode ainda conter problemas linguísticos que não foram objeto de revisão integral.

`docs/hoenn-coverage.json` registra contagens, IDs corrigidos e SHA-256 dos dois XMLs. O gerador divide os dados em 21 arquivos para respeitar os limites de constantes do LuaJIT. Os XMLs, ROMs e o ZIP espanhol não são distribuídos nesta implementação.

## Validação executada

- Os 37 arquivos Lua do mod compilam no LuaJIT.
- Testes de seleção dos três jogos, jogo desconhecido, proteção contra endereço incompatível, tradução inglesa ambígua, variáveis, símbolos, controles não suportados e patches que preservam campos de gameplay.
- Sobre o cache real de Emerald: **8.042 de 15.656 chaves de texto** recebem tradução; há aliases, portanto chaves não equivalem a falas únicas. Foram usadas **6.135 das 6.158 entradas do XML** no registro de diálogos. As outras 23 não tiveram aplicação segura nesse registro.
- Os 1.262 textos do cache que contêm controles não reconhecidos permanecem intactos; essa contagem inclui textos fora do XML.
- Simulações de Ruby e Sapphire com o corpus de Emerald validam roteamento e exclusão de endereços/ambiguidades. **Não medem cobertura de ROMs Ruby/Sapphire**: essas ROMs não estavam disponíveis localmente.
- Não houve teste visual em uma sessão de jogo, nem alteração ou execução da instalação estável. Não há garantia de encaixe visual de todas as falas; quebras e parágrafos vêm do XML.
- Os catálogos, fontes e demais arquivos legados de FRLG foram mantidos byte a byte. Em `main.lua` só foi acrescentado o encaminhamento inicial.

## Reproduzir

Na pasta do mod:

```sh
python tools/build_hoenn.py '/caminho/dump_BPE_en(1).xml' '/caminho/dump_BPE_pt-BR_zambrakas(1).xml'
luajit tests/hoenn.lua
luajit tests/hoenn.lua '/caminho/emerald/data/generated/gba/scripts/text.lua'
```

## Release local e estado do trabalho

O ZIP mantém `manifest.json`, `main.lua`, `hoenn.lua` e `lang/` na raiz, como o formato do mod de referência. O código-fonte, gerador, testes e relatório acompanham o pacote.

Os pacotes ficam separados, em `APrendizado/gen3_frlg_pt-br_mod/releases/`, ao lado do projeto local. Nenhum pacote foi instalado na pasta `mods/`, e nenhum outro mod foi alterado. A instalação/ativação para teste visual fica para uma etapa posterior.

A pedido do usuário, nenhum commit, push, fork ou pull request foi criado. O repositório original é de LordSangreal; a conta autenticada nesta sessão tem acesso de leitura, sem permissão de push direto.
