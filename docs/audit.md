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
