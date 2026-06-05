# The Legend of Ink

The Legend of Ink é um jogo 2D do gênero RPG de turno e aventura com mapa em tiles. O projeto acompanha Ink, um herói misterioso feito de tinta que acorda sem memória em um mundo sendo corrompido por gosmas pretas.

## Proposta

O objetivo do protótipo é oferecer uma experiência curta, com até meia hora de duração, focada em exploração, narrativa, coleta de itens, interação com NPCs e combate simples por turnos.

## Gênero

- RPG de turno
- Aventura 2D
- Exploração em mapa tile

## Mecânicas planejadas

- Exploração em mapas 2D
- Sistema de inventário
- Coleta de itens no mapa
- Diálogos com NPCs
- Combate simples por turnos
- Missões e pontos de interesse
- Economia simples
- Salvamento local

## Algoritmos computacionais

### Travelling Salesman Problem (TSP)

O TSP será usado para calcular uma rota curta entre vários pontos importantes do mapa, como coletáveis especiais ou pontos de interesse ativos da missão. A ideia é permitir que o jogador visualize uma ordem eficiente de visita entre esses pontos.

### Inventário e ordenação

O inventário armazenará itens coletados pelo jogador e permitirá adicionar, remover, consultar, equipar, consumir e descartar itens. A ordenação automática poderá organizar os itens por nome, tipo ou valor usando Quicksort.

### Pathfinding

O jogo também prevê pathfinding em mapa tile para movimentação de personagens, usando A* para encontrar caminhos entre dois pontos enquanto desvia de obstáculos.

## Tecnologias previstas

- Godot Engine
- GDScript
- JSON
- SQLite

## Como rodar

O projeto ainda está em fase inicial, quando o código do jogo for adicionado ao repositório, os passos para execução serão documentados aqui.
