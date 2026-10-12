# Auditoria da main — 12/10/2026

Referência inspecionada: `7d7077aea3714a86c719201f1566dfecbfd7fd26`.
Última publicação oficial anterior ao trabalho: GitHub Actions `38282687113`,
concluída com sucesso. O repositório é público e tem main como branch padrão.

| Item | Constatação |
| --- | --- |
| project.godot | Menu inicial; Compatibility ativo; ações dos três personagens existentes |
| menu_inicial.gd/.tscn | Menu com JOGAR e comandos em texto; sem setas Unicode |
| mundo_rafinha.tscn | Três personagens, câmera em Rafinha, sprites da família e scripts embutidos |
| character_body_2d.gd | Rafinha: velocidade 300, pulo -400, ações ui_left/ui_right/ui_accept |
| Bigo na cena original | A/D, V e E; reutiliza pum_bigo.tscn |
| Marina na cena original | 1/3 e L |
| Mina.tscn | Área que remove personagens e anima explosão; preservada no jogo original |
| pum_bigo.tscn | Efeito original com AnimationPlayer; reutilizado na aventura |
| SVGs | Desenhos originais presentes e reutilizados para os protagonistas, sol e chão |
| Recursos ausentes | Personagens/Mar.svg e Personagens/PranchaRafinha.svg |
| Pacote antigo | Continha texturas importadas do mar e da prancha; recuperadas como PNGs |
| export_presets.cfg | Preset Web existente, thread_support=false, sem extensão nativa ou service worker |
| deploy-web.yml | Exporta Godot 4.5.2 e publica um pacote Pages em pushes na main |
| Pages | Uma única publicação; um segundo deploy isolado substitui o pacote inteiro |

A branch adiciona os PNGs recuperados e muda somente as duas referências ausentes
na cena original. As outras cenas e os SVGs originais permanecem preservados.
O bloco `[input]` mantém todos os eventos anteriores sem alterações. Velocidades
e forças de pulo originais permanecem na aventura; buffer e tolerância curta de
pulo facilitam o uso por crianças sem trocar as teclas.

Quatro arquivos de fotografias foram acessados e inspecionados visualmente.
Dois arquivos apresentam a mesma fotografia frontal; os demais mostram detalhes
do rosto e perfil. Nenhuma fotografia foi colocada no checkout do repositório.

## Nova expansão — continuidade auditada

A main permaneceu em `7d7077aea3714a86c719201f1566dfecbfd7fd26`.
Antes da expansão da preguiça, foram verificadas as branches e os PRs abertos:
`feature/castle-dog-rescue-adventure` estava em
`1b98f2cd9203408e89f7b468a2c7112b2a9d88f7`, com o PR #1 em rascunho, ainda não
incorporado. Essa branch continha o catálogo de três fases, a Fófins, o amigo
provisório, o sistema de resgate/coleiras, o salvamento e a publicação isolada.
A nova `feature/sloth-poop-richard-two-castles` parte desse commit e preserva
seu histórico. Não foi criada outra implementação incompatível.

J/K/U/I não estavam em uso nas ações dos protagonistas. Foram adicionadas ações
próprias da preguiça, mantendo os eventos antigos. O workflow oficial, o script
original dos personagens e as cenas Mina/pum/menu permanecem idênticos à main.
A cena mundo_rafinha mantém somente as duas correções de imagens ausentes já
feitas na expansão anterior. As fotografias de Fófins não foram copiadas; seus
quatro SVGs também permanecem iguais aos da expansão anterior.

O segundo cão agora é Tokio, fêmea e preta. O ID antigo no save é migrado para
`tokio`; não é necessário apagar o progresso para receber a expansão. As duas
novas fases foram acrescentadas após os três castelos inspecionados.
