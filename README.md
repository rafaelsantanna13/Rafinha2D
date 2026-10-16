# Rafinha2D — A aventura dos castelos

Jogo infantil em **Godot 4.5.2 Standard**, com os desenhos originais da família.
Rafinha, Bigo, Marina, Guilherme Jedi e a preguiça atravessam cinco castelos,
resgatando Fófins, Tokio, Snoopy e oito amigos de identidades provisórias.

**Site oficial:** https://rafaelsantanna13.github.io/Rafinha2D/

## Jogar

Clique JOGAR para começar ou CONTINUAR para abrir o castelo salvo.
Chegue pertinho de cada cachorro e espere um instante para resgatar.
Rafinha segura as guias por padrão; o Help permite passá-las para Bigo.
Fófins sempre é a primeira cachorrinha. Tokio é fêmea e toda preta.

| Personagem | Andar | Pular | Especial |
| --- | --- | --- | --- |
| Rafinha | Setas esquerda/direita | Espaço | F: judô misterioso |
| Bigo | A / D | V | E: pum original |
| Marina | 1 / 3 | L | — |
| Preguiça | J / K | U | I: recolher cocô próximo |
| Guilherme Jedi | Z / X | B | Q: Força |

H ou Esc abre Help/pausa. T alterna a ajuda dos amigos humanos; C reúne esses
amigos. M liga ou desliga o som e a música (também no menu e na Ajuda). A preguiça continua controlável e vem automaticamente quando fica para
trás perto da borda. A câmera considera sua posição para mantê-la no enquadramento.
As suas teclas sempre têm prioridade sobre esse acompanhamento.

Os cabeçudinhos patrulham passagens e têm colisão. F faz o judô misterioso da
Rafinha e Q usa a Força do Guilherme para afastá-los. Eles ficam tontos e a
passagem abre, sem dano, mortes ou perda de vidas.

## Castelos

1. Castelo da Fófins: primeiro resgate.
2. Castelo dos Amigos: resgate de Tokio.
3. Castelo das Patinhas: três patinhas nas plataformas.
4. Castelo dos Muitos Cachorros: **Snoopy é o resgate principal**, dormindo no
   telhado de sua casinha vermelha; outros quatro amigos também esperam ali.
5. Castelo da Toca Secreta: quatro amigos, exploração e uma descoberta.

[Guia dos responsáveis — contém spoiler](docs/expansion-parent-guide.md).
JOGO ORIGINAL abre a cena mundo_rafinha.tscn preservada.

## Cocôs e progresso

Cada cachorro resgatado pode produzir cocô no chão com um temporizador; há no
máximo 12 objetos por fase. A preguiça usa I quando está perto.

Quando ninguém está comandando a preguiça, ela recolhe os cocôs sozinha, mas
bem do jeito dela: ignora cocôs com menos de 6 segundos, cochila ("Zzz..."),
boceja e se espreguiça por 2 segundos, anda a 70 px/s (a velocidade normal é
180), demora 1,5 segundo para pegar e depois descansa de 8 a 12 segundos. Ela
só vai atrás de cocôs no mesmo andar e dentro da tela, e desiste se demorar mais
de 15 segundos. Qualquer tecla dela (J, K, U, I) tem prioridade imediata. A coleta anima
os personagens e aumenta um contador. Objetos no chão são limpos nas transições.

Fases, cães, opções e total recolhido ficam em user://castle_adventure_v1.json.
O formato atual é versão 3 e aceita os formatos anteriores. Um progresso que
já passou do quarto castelo volta a ele para resgatar Snoopy, preservando os
outros cães e o contador. O antigo amigo provisório é convertido para Tokio.

Na Web, uma cópia imediata em localStorage protege recarregamentos rápidos;
o arquivo Godot/IndexedDB também é mantido para compatibilidade.
O armazenamento é local ao navegador, computador e endereço do site. Não há
sincronização em nuvem nem transferência automática entre o preview e o site
oficial. JOGAR confirma o reinício quando já existe progresso. Patinhas e a
surpresa recomeçam ao revisitar a fase, mantendo os resgates e fases concluídas.

## Som

A música animada (um loop de 16 compassos a 150 BPM, em Dó maior) e os efeitos
de pulo, resgate com latido, judô, Força, pum, cocô, patinha, porta e bocejo da
preguiça são sintetizados por `scripts/generate_audio.py`, somente com a
biblioteca padrão do Python. Nenhum áudio gravado ou de terceiros foi incluído.
O autoload `AdventureAudio` toca a música em todas as telas, e a escolha de som
ligado/desligado fica salva com o progresso. Os navegadores só liberam o áudio
depois do primeiro clique ou tecla.

## Desenvolvimento e testes

Abra project.godot no Godot 4.5.2 Standard, Compatibility, e execute F5.

```bash
godot --headless --path . --editor --import --quit
godot --headless --path . --fixed-fps 60 --script tests/run_adventure.gd -- --adventure-tests
python3 -m unittest discover -s tests -p 'test_*.py'
python3 scripts/validate_project.py
```

O teste usa um save separado. O Actions instala os templates Web oficiais,
exporta o jogo e percorre as cinco fases no Google Chrome usando teclado/mouse.
A observabilidade window.rafinhaAdventure é somente leitura e não oferece
atalhos de teleporte, resgate ou conclusão. O workflow da main testa antes da
publicação e percorre também o endereço oficial depois do deploy.

O catálogo central define cães, resgates, plataformas e fases. Os componentes
reutilizáveis ficam em adventure/actors, dogs, poop, combat e events. Os SVGs
transparentes são reproduzíveis por scripts/generate_art.py. Nenhuma fotografia
original foi incorporada ao repositório ou à exportação; a arte de Fófins foi
preservada da expansão anterior.

Os nomes dos oito amigos e a aparência dos novos desenhos ainda podem ser
escolhidos pela Rafaela. A expansão foi integrada à main conforme a autorização
do responsável; isso não substitui a avaliação da diversão pela criança.
