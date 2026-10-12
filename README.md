# Rafinha2D 🎮

Jogo 2D desenvolvido no **Godot 4.5** para a Rafaela, com personagens e cenários desenhados pela família.

## Estado do projeto

- O projeto original foi recuperado e aberto com sucesso no Godot 4.5.2.
- O jogo executou em um computador com o renderizador **Compatibility / OpenGL 3**.
- Próximos passos: importar todos os arquivos-fonte neste repositório, testar e preparar uma versão HTML5 para navegador.

## Como abrir no Godot

1. Baixe ou clone este repositório.
2. Inicie o Godot 4.5.2 Standard.
3. Importe o arquivo `project.godot` na raiz do repositório.
4. Escolha o renderizador **Compatibility** caso o computador não suporte Vulkan/Direct3D 12.
5. Execute o jogo com **F5**.

## Cuidados com o versionamento

Versionar `project.godot`, scripts `.gd`, cenas `.tscn` e imagens originais (`.svg`, `.jpg`). Não enviar o diretório de cache `.godot/`. Preferir preservar os arquivos-fonte em vez de depender apenas de exportações `.pck`.

> Ainda é preciso adicionar os arquivos do jogo a este repositório. Este README documenta a recuperação, não declara uma versão Web pronta.
