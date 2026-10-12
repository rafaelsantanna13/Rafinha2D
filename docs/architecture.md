# Arquitetura e escolhas provisórias

Cada cena de castelo possui um `level_index` e usa o mesmo construtor. O catálogo
define nome, cores, plataforma e cachorro daquele castelo. O estado global guarda
IDs dos cachorros, fase atual, fases concluídas e fase desbloqueada.

O resgate reutilizável é uma Area2D. Um protagonista permanece em sua área por
0,45 segundo, o cachorro celebra e seu ID entra no estado global. Resgates
duplicados são ignorados. Fófins precisa ser a primeira cachorrinha. Qualquer
protagonista pode ajudar no resgate; o percurso e os testes apresentam Bigo como
resgatador, mantendo também a participação jogável de Rafinha e Marina.

Rafinha segura as guias por padrão. A opção na ajuda permite transferi-las para
Bigo. Não são implementadas forças físicas nas guias: elas são visuais para
evitar que prender um cachorro numa quina imobilize uma criança.

Os cachorros seguem uma trilha espacial do condutor, incluindo altura dos pulos.
O espaçamento é 112 pixels e o movimento tem aceleração e desaceleração graduais.
Uma Curve2D liga a mão do condutor à coleira de cada cachorro. Isso evita um
cachorro tentar atravessar sozinho uma plataforma que não consegue alcançar.
A trilha e as posições são reconstruídas em cada castelo usando a lista global;
os IDs e resgates são preservados, não referências a nós de uma cena anterior.

A ajuda dos amigos segue o protagonista controlado mais recentemente, pula
degraus e recupera um amigo que ficou muito longe. Uma tecla manual sempre tem
prioridade. Essa ajuda pode ser desligada para manter cada personagem parado
quando suas teclas não são usadas. C reúne o grupo e reinicia a trilha em casos
de separação. Essas são escolhas de acessibilidade, não decisões da história.

Não há buracos letais, inimigos ou minas nas três fases novas. As plataformas têm
degraus de 55 pixels, compatíveis com o pulo original de -400 e gravidade padrão.
O último castelo pede três patinhas antes da festa. Segundo cachorro, castelo
final e desafio são provisórios, identificados como tal na interface.

O arquivo de progresso usa uma escrita temporária e renomeação. Saves inválidos
não substituem o estado já carregado. Falhas de escrita geram uma mensagem e não
impedem o jogo. Na Web, o user:// depende do IndexedDB do navegador, conforme a
[documentação Godot 4.5](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_web.html).
Não há sincronização entre dispositivos nem coleta de dados pessoais.

`window.rafinhaAdventure` fornece somente informações para os testes de navegador:
fase, posições, IDs resgatados, patinhas e retângulos dos botões do menu.
Não expõe funções para teleportar, resgatar ou avançar fases. O teste navegador
percorre a aventura com teclado e mouse reais.

A hospedagem alternativa serve a exportação Godot em um Site privado do
proprietário. O loader do HTML descompacta somente a resposta WASM com gzip;
a engine e o pacote do jogo continuam sem alteração. A exportação padrão
sem compactação continua disponível para GitHub Pages e outras hospedagens.
