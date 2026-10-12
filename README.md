# Rafinha2D — A aventura dos castelos

Jogo infantil em **Godot 4.5.2 Standard**, com os desenhos originais da família.
Nesta branch experimental, Bigo, Rafinha e Marina atravessam três castelos,
resgatam Fófins e um amigo provisório e chegam juntos a uma festa.

- Oficial: https://rafaelsantanna13.github.io/Rafinha2D/
- Experimento jogável (Sites, login na conta do proprietário): https://rafinha2d-castelos-teste.clean-aspen-8728.chatgpt.site
- Endereço planejado /teste/: depende de autorização da branch no ambiente GitHub Pages
- Branch: `feature/castle-dog-rescue-adventure`

A **main não foi modificada**. O experimento ainda depende da avaliação da Rafaela.

## Jogar

Abra o experimento em um computador e clique **JOGAR**.
Chegue pertinho de um cachorro e espere um instante para resgatar.
Após o resgate, avance até a porta do próximo castelo.
No terceiro castelo, recolha as três patinhas nas plataformas e encontre a festa.

| Personagem | Andar | Pular | Especial |
| --- | --- | --- | --- |
| Rafinha | Setas esquerda/direita | Espaço | Conduz as guias por padrão |
| Bigo | A / D | V | E: pum original |
| Marina | 1 / 3 | L | — |

**H ou Esc:** ajuda/pausa. **T:** alternar ajuda dos amigos.
**C:** reunir os personagens e cachorros.
Os amigos acompanham quem está sendo controlado quando a ajuda está ligada.
Todos continuam jogáveis pelas suas próprias teclas, inclusive simultaneamente.
A ajuda pode ser desligada no menu ou com T.
Na ajuda, também é possível trocar as guias entre Rafinha e Bigo.

**CONTINUAR** abre o castelo salvo. **JOGAR** inicia outra aventura;
quando existe progresso, uma confirmação evita apagá-lo por acidente.
**JOGO ORIGINAL** abre a cena `mundo_rafinha.tscn` preservada.

## Salvamento

Fases concluídas, fase desbloqueada, cachorros resgatados e opções ficam em
`user://castle_adventure_v1.json`. Na Web, o armazenamento é local ao navegador
e ao computador. Não há sincronização em nuvem. Bloqueios de armazenamento são
informados sem impedir o jogo. As patinhas do desafio final recomeçam ao voltar
para esse castelo; os cachorros e as fases concluídas continuam salvos.

## Abrir e testar no Godot

Importe `project.godot` no **Godot 4.5.2 Standard**, renderer **Compatibility**,
e execute F5. Não é necessário instalar addons no Godot.

```bash
godot --headless --path . --editor --import --quit
godot --headless --path . --fixed-fps 60 --script tests/run_adventure.gd -- --adventure-tests
python3 -m unittest discover -s tests -p 'test_*.py'
python3 scripts/validate_project.py
mkdir -p build/preview
godot --headless --path . --export-release Web build/preview/index.html
python3 scripts/validate_project.py build/preview
```

Os testes usam um arquivo de salvamento separado e nunca apagam progresso real.
Para o teste Web completo, instale as dependências de teste com `npm ci`,
execute `npx playwright install --with-deps chromium`, sirva `build/preview`
com `python3 -m http.server 8765 --directory build/preview` e execute
`npm run test:web` em outro terminal.

## Organização

- `adventure/catalog.gd`: castelos, identidade dos cachorros e cores.
- `adventure/state.gd`: progressão, salvamento e validação.
- `adventure/actors/`: três personagens com os desenhos e comandos originais.
- `adventure/dogs/`: resgate por proximidade, estados visuais, trilha e guias.
- `adventure/levels/`: cenas independentes e construtor compartilhado de fases.
- `adventure/art/`: SVGs transparentes dos cachorros e cenários.
- `scripts/generate_art.py`: fonte reproduzível dos desenhos novos.
- `tests/`: testes Godot, navegador e preservação da publicação.

Para adicionar um castelo, crie outra cena com `castle_level.gd`, um índice novo
e uma entrada em `CastleCatalog.LEVELS`. Um novo cachorro entra em `DOGS`, com
identificador, nome, prefixo dos quatro SVGs e cor da coleira. A lista de resgates
e a formação crescem com o catálogo. A primeira cachorrinha permanece Fófins.

## Publicação experimental

O workflow `adventure-preview.yml` executa os testes e exporta o Godot da branch.
Também prepara uma composição com **os nove arquivos da versão oficial já publicada, sem reconstruí-los**,
para a raiz do pacote Pages e acrescenta a exportação em `/teste/`.
Hashes SHA-256 e uma verificação da versão oficial antes da publicação impedem
que o pacote experimental substitua o conteúdo do jogo oficial.

O workflow original da main e a configuração do Pages continuam intactos.
**Limitação:** uma publicação futura pelo workflow original da main pode remover
`/teste/`, pois GitHub Pages publica um único pacote por vez. Nesse caso, execute
novamente o workflow experimental selecionando esta branch; ele preservará a
versão oficial mais recente e restaurará o teste. A retenção permanente do
subdiretório em futuras publicações exige aprovar uma atualização do workflow
oficial. Nenhuma alteração desse tipo foi aplicada à main.

O ambiente `github-pages` deste repositório autoriza somente a main. A tentativa
de publicar a feature foi rejeitada por essa proteção, que foi preservada.
Por isso o experimento foi publicado separadamente em **Sites**, com acesso
privado pela conta do proprietário. O deploy Pages está desligado por padrão;
`workflow_dispatch.publish_pages` só deve ser usado depois de autorizar a branch.

A publicação Sites usa a exportação real do Godot. O WASM é compactado sem
perda e descompactado no navegador, preservando os mesmos bytes da engine.
Chrome, Edge ou Firefox atualizados são recomendados. `prepare_free_preview.py`
produz o pacote e um teste Chromium verifica esse carregamento. O GitHub Actions
sempre fornece um artefato `free-preview-export`; uma atualização do preview
Sites é feita pelo Work a partir dessa exportação, sem alterar a main.

As capturas e o relatório de navegador ficam em [docs/screenshots](docs/screenshots).
O manifesto da composição Pages fica no artefato `github-pages` do workflow.
Pull requests executam verificações, mas não publicam.

## Decisões ainda da Rafaela

Os três castelos são uma demonstração técnica. Nome e desenho do segundo
cachorro, quantidade definitiva de castelos e desafio final estão abertos.
Os resgates não inventam vilões nem a razão de os cachorros estarem nos castelos.

Fófins foi desenhada em SVG usando as quatro fotografias fornecidas como
referência: pelagem clara, orelhas castanhas, rosto bege/marrom, olhos grandes,
nariz preto, focinho curto e pelos na testa. **As fotos originais não fazem parte
do repositório nem da exportação.**

Consulte [a auditoria](docs/audit.md), [a arquitetura](docs/architecture.md) e
[o relatório de verificações](docs/test-report.md).
