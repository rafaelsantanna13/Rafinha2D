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
| Produção real | Snapshot dos sete arquivos publicados e confirmação SHA-256 | Passou |

**58 verificações Godot e 4 testes Python passaram.** O arquivo de progresso dos
testes é isolado do arquivo usado pela família.

## Navegador e revisão visual

O workflow experimental instala Chromium e executa `tests/web_adventure.cjs`.
Ele abre o WASM, usa os comandos reais, resgata os dois cães, percorre os três
castelos, recarrega o navegador para validar IndexedDB e captura a festa.
O resultado final da execução e a revisão das capturas serão registrados aqui
após a publicação experimental.

## Avaliação que cabe à Rafaela

Reconhecer Fófins, aprovar nome e desenho do amigo, preferir os temas dos castelos
e avaliar a dificuldade dos pulos. A aparência e diversão precisam dessa
avaliação humana; um teste automatizado não pode aprovar a história por ela.
