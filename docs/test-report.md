# Relatório de verificações

Engine utilizada: **Godot 4.5.2 Standard**, `4.5.2.stable.official.6ce3de25a`.

## Executadas localmente

| Verificação | Método | Resultado |
| --- | --- | --- |
| Carregamento de oito cenas | Godot headless, incluindo cenas originais e os três castelos | Passou |
| Scripts | Importação, execução e testes com inspeção de erros | Passou, sem erros críticos |
| Ações de teclado | InputEventKey físico: ambos os sentidos e pulo dos três personagens; E do Bigo | Passou |
| Resgate Fófins | Proximidade real na Area2D, inclusão no estado e acompanhante | Passou |
| Resgate inicial e duplicado | Fófins obrigatoriamente primeira; resgate não duplicado | Passou |
| Acompanhamento | Caminhada, parada gradual, espaçamento, trilha com pulo e troca de condutor | Passou |
| Progressão | Portas bloqueadas antes do objetivo, duas transições e festa final | Passou |
| Estado entre cenas | Fófins no segundo castelo e dois cães no terceiro | Passou |
| Salvamento | Gravação/leitura, arquivo corrompido, falha de escrita e reinício | Passou |
| Arte | Importação dos oito SVGs dos cachorros, XML válido, ausência de imagens externas | Passou |
| Exportação Web | Template oficial 4.5.2, arquivos HTML/JS/WASM/PCK e execução sem threads | Passou |
| Publicação isolada | Quatro testes Python: cópia exata, recusa de destino existente, mudança da produção e exportação incompleta | Passou |
| Produção real | Snapshot dos nove arquivos publicados, incluindo AudioWorklets e confirmação SHA-256 | Passou |

**59 verificações Godot e 4 testes Python passaram.** O arquivo de progresso dos
testes é isolado do arquivo usado pela família.

## Navegador e revisão visual

O workflow experimental instala Chromium e executa `tests/web_adventure.cjs`.
Ele abre o WASM, usa os comandos reais, resgata os dois cães, percorre os três
castelos, recarrega o navegador para validar IndexedDB e captura a festa.
A execução completa no Chromium passou em **12 verificações**, incluindo dois
resgates, três fases, festa e dois recarregamentos com IndexedDB. O carregamento
da exportação compactada da hospedagem alternativa também passou, abrindo o
menu e o primeiro castelo sem erros. As capturas de menu, resgates e festa foram
inspecionadas visualmente; foram corrigidos contraste, tamanho de Marina,
ligação das guias às coleiras e espaçamento dos acompanhantes.

Execução Web de referência: [38292205748](https://github.com/rafaelsantanna13/Rafinha2D/actions/runs/38292205748).
As imagens estão em [screenshots](screenshots/).

O teste manual em um teclado físico da família e a avaliação da diversão pela
Rafaela continuam pendentes. Não foi simulado que esses testes pessoais ocorreram.

A publicação em /teste/ foi impedida pela regra do ambiente github-pages, que
autoriza somente a main. O workflow permanece com deploy manual opcional e
verificações automáticas. O preview foi publicado separadamente em [Sites](https://rafinha2d-castelos-teste.clean-aspen-8728.chatgpt.site),
com acesso privado do proprietário; a main, seu
workflow e os arquivos oficiais publicados continuam intactos.

## Avaliação que cabe à Rafaela

Reconhecer Fófins, aprovar nome e desenho do amigo, preferir os temas dos castelos
e avaliar a dificuldade dos pulos. A aparência e diversão precisam dessa
avaliação humana; um teste automatizado não pode aprovar a história por ela.

## Publicação confirmada

Preview: https://rafinha2d-castelos-teste.clean-aspen-8728.chatgpt.site

A publicação Sites foi confirmada como succeeded. Exige login na conta do
proprietário. O pacote publicado contém o export Godot; SHA-256 do WASM após
descompactar: `6ead2ac528d007fe9627aae650444f9187f89420d7603c22460d8f3279545240`.
A inspeção visual foi feita nas capturas Chromium, não em uma sessão manual
da família. Nenhuma publicação foi feita na main nem no endereço oficial.
