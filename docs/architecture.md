# Arquitetura anterior — histórico

A atualização atual está descrita em [jedi-judo-snoopy.md](jedi-judo-snoopy.md).
Ela substitui a regra abaixo de preguiça exclusivamente manual, inclui combate
cômico e o resgate de Snoopy, e está autorizada para a main.

# Arquitetura e escolhas provisórias

Cada cena de castelo possui um `level_index` e usa o mesmo construtor. O catálogo
define nome, cores, plataformas e um dicionário de resgates com posições para cada castelo. O estado global guarda
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
quando suas teclas não são usadas. C reúne os três protagonistas e reinicia a trilha em casos
de separação. A preguiça tem can_auto_follow=false, allow_recovery=false e
velocidade 180: nenhuma ajuda, recuperação automática ou comando C a move.
Seu componente estende o controlador comum e acrescenta a coleta por I. Essas são escolhas de acessibilidade, não decisões da história.

As três cenas anteriores permanecem na progressão. O antigo final se chama
Castelo das Patinhas e mantém o desafio antes dos dois novos castelos. A quarta
fase tem quatro resgates. A quinta tem quatro resgates e um buraco explorável,
com chão dividido, piso inferior e degraus dos dois lados. Richard usa uma
Area2D, com estados HIDDEN, APPEARING e VISIBLE. Só a proximidade manual revela
o coelho. As colisões permitem entrar e sair; pulos de -400 vencem os degraus
de 55 pixels mesmo com a velocidade menor da preguiça.

O gerenciador de cocôs aplica um prazo a cada acompanhante (primeira espera de
8 a 14 segundos, depois 27 a 33 segundos). Um raycast encontra piso próximo e
um teste de ponto rejeita paredes. Cães no ar não geram objetos. Há no máximo
12 objetos; tentativas sem piso ou com limite atingido esperam três segundos.
Um cocô fica coletável até I ser usado pela preguiça a até 82 pixels e 35 pixels
de diferença vertical. O objeto sai da lista imediatamente, anima por 0,25s e
é liberado; o ator anima a coleta por 0,55s. O total vai ao estado persistente.
O gerenciador é desativado e limpo antes de cada transição. A festa não o cria.

O arquivo de progresso usa uma escrita temporária e renomeação. Saves inválidos
não substituem o estado já carregado. Falhas de escrita geram uma mensagem e não
impedem o jogo. Na Web, o user:// depende do IndexedDB do navegador, conforme a
[documentação Godot 4.5](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_web.html).
A versão 2 usa o mesmo caminho anterior e migra amigo_provisorio para tokio.
Uma versão 1 concluída libera o quarto castelo. Não há sincronização entre dispositivos nem coleta de dados pessoais.

`window.rafinhaAdventure` fornece somente informações para os testes de navegador:
fase, posições, IDs resgatados, patinhas, cocôs, estado do evento, Help,
plataformas e retângulos dos botões do menu.
Não expõe funções para teleportar, resgatar ou avançar fases. O teste navegador
percorre a aventura com teclado e mouse reais.

A hospedagem alternativa serve a exportação Godot em um Site privado do
proprietário. O loader do HTML descompacta somente a resposta WASM com gzip;
a engine e o pacote do jogo continuam sem alteração. A exportação padrão
sem compactação continua disponível para GitHub Pages e outras hospedagens.
