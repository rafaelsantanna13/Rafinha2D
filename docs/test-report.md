# Verificações da expansão da preguiça

Engine: **Godot 4.5.2 Standard**, `4.5.2.stable.official.6ce3de25a`.

## Execução funcional automatizada

**134 verificações Godot e quatro testes Python passaram**, localmente e no
GitHub Actions. O arquivo de progresso dos testes é isolado do da família.
O teste de navegador percorreu a exportação real com teclado e mouse, sem
teleporte, alteração de estado ou atalhos de resgate pelo JavaScript.

| Requisito | Evidência executada | Resultado |
| --- | --- | --- |
| Cenas e scripts | Importação sem erros, instanciação de 11 cenas e execução das cinco fases | Passou |
| Recursos visuais | 40 texturas dos cães importadas; todos os SVGs têm XML válido e não incorporam fotos | Passou |
| Controles originais | InputEventKey físico, direita/esquerda/pulo dos três personagens e E do Bigo | Passou |
| Controles da preguiça | J/K/U movimentam o ator real; I aciona coleta e animação | Passou |
| Conflitos de teclado | Comparação das ações físicas de todos os personagens | Nenhum |
| Preguiça manual | Ajuda ligada, grupo distante e C não mudam sua posição horizontal | Passou |
| Cocô por temporizador | Cachorro resgatado gera objeto no piso e anima sua pose | Passou |
| Geração segura | Rejeita ar, paredes e regiões abaixo do cenário | Passou |
| Limite de cocôs | Geração e temporizador respeitam o limite simultâneo | Passou |
| Coleta por proximidade | I longe e acima do piso não recolhe; perto recolhe e incrementa total | Passou |
| Desaparecimento | Sai da lista, anima e libera o objeto; não coleta duas vezes | Passou |
| Transição e festa | Desativação/limpeza explícita; festa não cria gerador | Passou |
| Resgates novos | Quatro cães na quarta fase e quatro na quinta; Fófins obrigatoriamente primeiro | Passou |
| Guias e formação | Caminhada, parada gradual, pulo, condutor configurável e formação de dez cães espaçados | Passou |
| Progressão | Três fases preservadas, duas adicionais e festa; portas exigem todos os resgates da fase | Passou |
| Buraco explorável | Entrada física, piso inferior e saída pelos degraus; preguiça sai com K/U | Passou |
| Richard | Escondido antes do gatilho, aparece por colisão real, continua visível e não vira cachorro | Passou |
| Salvamento | Leitura, escrita, corrupção, indisponibilidade, recuperação e reinício | Passou |
| Compatibilidade | Save anterior mantém Fófins, converte Tokio e abre a quarta fase após o final antigo | Passou |
| Web | Templates oficiais 4.5.2, Compatibility e execução sem threads | Passou |
| Navegador | Percurso dos cinco castelos e coleta no Google Chrome 154.0.8037.97 | Passou |
| Produção | Nove arquivos oficiais copiados e comparados por SHA-256; main e workflow oficial intactos | Passou |

A execução Chromium [38307737629](https://github.com/rafaelsantanna13/Rafinha2D/actions/runs/38307737629)
passou em **23 verificações**, mais o carregamento da exportação compactada.
Incluiu Help, controle manual, coleta, Tokio, oito novos resgates, buraco,
Richard, saída, festa e salvamento após recarregar. Sem erros críticos.

## Falhas encontradas e corrigidas

- A versão numérica do JSON precisava de conversão antes da comparação com o
  catálogo de versões; a leitura e a migração foram corrigidas e retestadas.
- O percurso automatizado pulava antes de um cocô localizado no piso inferior;
  a coleta recusou corretamente. O teste passou a parar antes da plataforma.
- O menu com CONTINUAR precisava manter sua altura; JOGAR/CONTINUAR ficaram em
  uma linha e a posição dos botões é verificada no navegador.
- O desenho da entrada da toca estava abaixo da camada do chão. A ordem das
  camadas foi corrigida e Richard recebe seu nome só após a descoberta.

## Pendências humanas e limites

A família ainda precisa avaliar diversão, dificuldade, desenhos e frequência
com seu teclado físico. Nenhum teste pessoal da Rafaela foi alegado.
As identidades dos oito amigos novos são provisórias. A frequência e o limite
podem ser alterados no gerenciador sem mudar os cães ou as fases.

O progresso Web depende do armazenamento local do navegador. Não há nuvem nem
sincronização entre computadores. Patinhas e surpresa recomeçam numa revisita;
resgates, fases e total recolhido permanecem salvos. Cocôs no chão são limpos
entre fases.

O ambiente github-pages continua aceitando somente a main. Não foi enfraquecido
nem utilizado para publicar esta feature. O preview separado usa Sites e
preserva o acesso privado do proprietário, com login na sua conta. O pacote
contém a engine Godot real, compactada sem perda para caber na hospedagem.

## Rodada final e publicação

A execução final [38308558823](https://github.com/rafaelsantanna13/Rafinha2D/actions/runs/38308558823),
no commit `b91615a41911bf4a67b59c1780daddee5222f277`, passou com:
**134 verificações Godot, quatro testes Python e 26 verificações no Google Chrome
154.0.8037.97**. O smoke test da exportação compactada passou. Não há falhas
pendentes nesses testes nem erros críticos de script/navegador. Os nove arquivos
oficiais passaram pela comparação SHA-256 novamente após preparar o preview.

Capturas inspecionadas:
[menu com progresso](screenshots/03b-menu-com-progresso.png),
[Help](screenshots/02b-help.png),
[coleta](screenshots/04b-coco-recolhido.png),
[Castelo dos Muitos Cachorros](screenshots/06-castelo-muitos-cachorros.png),
[festa com dez cães](screenshots/08-festa.png).
A [toca de Richard](screenshots/07-toca-richard-responsaveis.png) contém spoiler
para os responsáveis. O relatório bruto fica em screenshots/browser-report.json.

Preview: https://rafinha2d-castelos-teste.clean-aspen-8728.chatgpt.site

O pacote publicado tem PCK SHA-256
`16a5b179e595cbdc1644292dd52dcd72310bceeb733b361535204c06f3b366b7`.
A descompactação do WASM preserva SHA-256
`6ead2ac528d007fe9627aae650444f9187f89420d7603c22460d8f3279545240`.
O acesso continua privado da conta do proprietário.

A publicação experimental foi confirmada como **succeeded** pelo provedor.
O preview usa o mesmo endereço da expansão anterior, agora com as cinco fases.
A main e a branch anterior permanecem nos commits inspecionados na auditoria.
