# Guilherme Jedi, judô misterioso e Snoopy

Esta continuação parte da expansão de cinco castelos do PR #2. A solicitação
mais recente autoriza sua integração à main e muda a regra anterior da
preguiça: agora ela alcança os personagens quando esquecida perto da borda.

## Implementação

Guilherme usa o controlador comum com teclas Z/X/B/Q, robe Jedi, animações e
ondas da Força. Rafinha ganha F para o judô. Um módulo de habilidades verifica
ator e distância: 130 pixels para o judô, 320 para a Força, com limite vertical.
Cabeçudinhos têm camada física própria, patrulha curta e reação de rodopio ou
afastamento. A reação desativa seu bloqueio durante aquela visita, sem morte
ou dano aos jogadores. Os comandos originais continuam iguais.

A preguiça permanece lenta nos comandos manuais. Na borda, usa velocidade de
recuperação para alcançar o grupo; a câmera enquadra ambos. J/K/U/I interrompem
esse acompanhamento. A função independe de T, que controla os amigos humanos.
C não a teleporta. Seu movimento continua sujeito a piso e colisões.

Snoopy é o objetivo principal do quarto castelo. O SVG de repouso o mostra
dormindo em cima da casinha vermelha, cujo telhado possui colisão e degraus
para alcançar. O resgate o acorda, anima e acrescenta à formação com coleira.
A fase exige Snoopy e os quatro resgates já existentes. São onze cães no total.

O save versão 3 aceita versões 1 e 2. Uma cópia local síncrona na Web evita
reverter de fase ao recarregar antes de terminar a sincronização IndexedDB.
O arquivo Godot permanece como compatibilidade e fallback. Quem já concluiu a aventura sem Snoopy
retorna ao quarto castelo, mantendo os cães anteriores e o total coletado.

## Verificação

O roteiro Godot executa controles reais, limite de alcance, bloqueio físico,
judô, Força, acompanhamento visível da preguiça, coleta, Snoopy, onze cães,
cinco fases, Richard e salvamento/migração. O navegador usa teclado/mouse e
lê somente estado; captura também Snoopy dormindo e depois do resgate.

O workflow deploy-web.yml publica somente a main depois de testes Godot,
integridade e exportação. A etapa verify-live percorre o próprio endereço
GitHub Pages no Google Chrome e confirma o marcador jedi-judo-snoopy-1.
As capturas e logs ficam nos artefatos do Actions, incluindo
**official-live-chrome-evidence** após a publicação oficial.

A validação com o teclado da família, diversão e aprovação dos desenhos pela
Rafaela continuam pendentes. Os relatórios anteriores documentam as versões
que ainda estavam isoladas em preview; a autorização atual permite publicação
na main.
