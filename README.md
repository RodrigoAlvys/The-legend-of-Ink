# The Legend of Ink

The Legend of Ink é um jogo 2D do gênero RPG de turno e aventura com mapa em tiles. O projeto acompanha Ink, um herói misterioso feito de tinta que acorda sem memória em um mundo sendo corrompido por gosmas pretas.

## Proposta

O objetivo do protótipo é oferecer uma experiência curta, com foco em exploração, narrativa, coleta de itens, interação com NPCs, missões e combate simples por turnos.

## Como rodar

1. Abra o Godot 4.x.
2. Importe a pasta `rp-gprojeto/`.
3. Abra `rp-gprojeto/project.godot`.
4. Execute a cena principal pelo editor.

## Controles

- `WASD` ou setas: mover Ink.
- `Shift`: correr.
- `E`: interagir com NPCs/objetos.
- `G`: coletar item no chão.
- `I`: abrir/fechar inventário.
- `J`: abrir/fechar menu de missões.
- `V`: mostrar/ocultar rota visual de pontos de interesse.

## Mecânicas implementadas

- Exploração em mapas 2D com troca de áreas.
- Sistema de inventário com itens consumíveis, equipáveis e de missão.
- Coleta de itens no chão com notificação e validação de espaço.
- Interface de inventário em tiles com ações de consumir, equipar, dropar e ordenar.
- Sistema de missões com HUD, menu e recompensas.
- Diálogos com NPCs.
- Rota visual entre pontos de interesse.

## Algoritmos computacionais

### Travelling Salesman Problem (TSP) - heurística gulosa

A rota entre pontos de interesse usa uma heurística gulosa semelhante ao vizinho mais próximo: a partir de um ponto, o sistema escolhe o próximo ponto ainda não visitado com menor distância conhecida. A distância entre os pontos é calculada sobre o mapa usando A*.

Aplicação no jogo: indicar uma rota eficiente entre pontos de interesse do mapa.

Complexidade aproximada da escolha gulosa: `O(n²)`, considerando `n` pontos de interesse.

### A* para pathfinding

O pathfinding calcula o caminho entre dois pontos do mapa tile, evitando células não navegáveis. O algoritmo usa custo ortogonal/diagonal e heurística octogonal.

Aplicação no jogo: gerar segmentos reais da rota visual entre pontos de interesse.

### Quicksort no inventário

O inventário pode organizar itens por nome, tipo e valor. A ordenação usa Quicksort in-place com pivô por mediana de três.

Aplicação no jogo: organizar os itens coletados pelo jogador.

Complexidade média: `O(n log n)`.

### DFS na árvore de missões

As missões são modeladas como árvores/grafos de etapas. Uma busca em profundidade (DFS) valida a profundidade máxima e evita seguir ciclos infinitos.

Aplicação no jogo: controlar ramificações narrativas, escolhas e progressão de missões.

Complexidade: `O(V + E)`, onde `V` são etapas e `E` são escolhas/conexões.

## Tecnologias

- Godot Engine 4.x
- GDScript
- Estruturas em Resource, Dictionary e Array

## Organização principal

- `rp-gprojeto/inventory/`: inventário, itens, coleta e ordenação.
- `rp-gprojeto/missions/`: missões, árvore de missão, HUD e menu.
- `rp-gprojeto/scripts/pathfinder/`: A*, rota gulosa e visualização de caminho.
- `rp-gprojeto/mapas/`: mapas e transições.
- `rp-gprojeto/jogador/`: cena e script do jogador.
