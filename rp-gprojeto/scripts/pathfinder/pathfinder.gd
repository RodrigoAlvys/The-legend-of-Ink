extends Node2D

@export var tilemap: TileMapLayer
@export_flags_2d_navigation var nav_mask: int = 1
@export var pontos_interesse: Array[Vector2]
@export var player: CharacterBody2D
@export var line: Line2D
@export var timer: Timer

const CUSTO_ORTOGONAL:int = 10
const CUSTO_DIAGONAL:int = 14
const INF_INT:int = 9999999999

# Dados do grid
var _grid_size_x: int = 0
var _grid_size_y: int = 0
var _navegavel: Array[Array] = []
var _cell_size: Vector2
var _cont_nav:int = 0

# Cache dos algoritmos
var _cache_distancias: Dictionary = {}
var _pontos_restantes: Array[int] = []
var _caminho_atual: Array[Vector2] =[]
var _indice_caminho:int = 0
var _guest_on:bool = true

func _ready() -> void:
	var _layer_mask: int = int(log(nav_mask)/log(2))
	if not _conf_grid(_layer_mask):
		print("Error ao configurar grid!")
		return

func _conf_grid(layer_mask: int) -> bool:
	var rect = tilemap.get_used_rect()
	
	if rect.size.x == 0 or rect.size.y == 0:
		print("Tilemap vazio")
		return false
	_grid_size_x = rect.size.x
	_grid_size_y = rect.size.y
	_cell_size = tilemap.tile_set.tile_size
	
	_navegavel.resize(_grid_size_y)
	for y in range(_grid_size_y):
		_navegavel[y] = []
		_navegavel[y].resize(_grid_size_x)
		for x in range(_grid_size_x):
			var cell = Vector2i(rect.position.x + x, rect.position.y + y)
			var source_id = tilemap.get_cell_source_id(cell)
			if source_id == -1:
				_navegavel[y][x] = false
				continue
			var tile_data = tilemap.get_cell_tile_data(cell)
			if tile_data == null:
				_navegavel[y][x] = false
				continue
			var _nav_polygon = tile_data.get_navigation_polygon(layer_mask)
			if _nav_polygon != null:
				_navegavel[y][x] = true
				_cont_nav += 1
			else:
				_navegavel[y][x] = false
	return (_cont_nav > 0)

func _mundo_to_grid(pos_mundo: Vector2) -> Vector2i:
	var rect:Rect2i = tilemap.get_used_rect()
	var cell:Vector2i = tilemap.local_to_map(pos_mundo)
	return Vector2i(cell.x - rect.position.x, cell.y - rect.position.y)

func _grid_to_mundo(pos_grid: Vector2i) -> Vector2:
	var rect:Rect2i = tilemap.get_used_rect()
	var cell_mundo:Vector2i = Vector2i(rect.position.x + pos_grid.x, rect.position.y + pos_grid.y)
	return tilemap.map_to_local(cell_mundo)

func _is_navegavel(pos_grid: Vector2i) -> bool:
	if pos_grid.x < 0 or pos_grid.x >= _grid_size_x:
		return false
	if pos_grid.y < 0 or pos_grid.y >= _grid_size_y:
		return false
	return _navegavel[pos_grid.y][pos_grid.x]

func _heuristica_octogonal(pos:Vector2i, goal:Vector2i) -> int:
	var dx:int = abs(pos.x - goal.x)
	var dy:int = abs(pos.y - goal.y)
	return min(dx, dy)*CUSTO_DIAGONAL + abs(dx-dy)*CUSTO_ORTOGONAL

func _pode_diagonal(de:Vector2i, para:Vector2i) -> bool:
	var dx:int = para.x - de.x
	var dy:int = para.y - de.y
	if abs(dx) != 1 and abs(dy) != 1:
		return true
	var passo_horizontal: Vector2i = Vector2i(de.x + dx, de.y)
	var passo_vertical: Vector2i = Vector2i(de.x, de.y + dy)
	return _is_navegavel(passo_horizontal) or _is_navegavel(passo_vertical)

func _vizinhos(pos:Vector2i) -> Array[Vector2i]:
	var vizinhos:Array[Vector2i] = []
	for y in range(-1, 2):
		for x in range(-1, 2):
			if y==0 and x==0:
				continue
			var viz = pos + Vector2i(x, y)
			if viz.y<0 or viz.y>=_grid_size_y or viz.x<0 or viz.x>=_grid_size_x:
				continue
			if not _is_navegavel(viz):
				continue
			if abs(y)==1 and abs(x)==1:
				if not _pode_diagonal(pos, viz):
					continue
			vizinhos.append(viz)
	return vizinhos

func _custo_mov(de:Vector2i, para:Vector2i) -> int:
	if abs(de.x - para.x) == 1 and abs(de.y - para.y) == 1:
		return CUSTO_DIAGONAL
	else:
		return CUSTO_ORTOGONAL
		
func _reconstruir_path(no_final:NoAStar) -> Array[Vector2]:
	var caminho_grid:Array[Vector2i] = []
	var atual:NoAStar = no_final
	
	while atual != null:
		caminho_grid.append(atual.pos)
		atual = atual.parent
	
	caminho_grid.reverse()
	
	var caminho_mundo:Array[Vector2] = []
	for pos_grid in caminho_grid:
		caminho_mundo.append(_grid_to_mundo(pos_grid))
	return caminho_mundo

func a_star_manual(inic_mundo:Vector2, fim_mundo:Vector2) -> Array[Vector2]:
	var inic:Vector2i = _mundo_to_grid(inic_mundo)
	var fim:Vector2i = _mundo_to_grid(fim_mundo)
	
	if not _is_navegavel(inic) or not _is_navegavel(fim):
		return []
	
	var open:Array[NoAStar] = []
	var close:Dictionary = {}
	
	var h_inic:int = _heuristica_octogonal(inic, fim)
	var no_inic:NoAStar = NoAStar.new(inic, 0, h_inic)
	open.append(no_inic)
	
	while open.size() > 0:
		var atual:NoAStar = open[0]
		var idx_atual:int = 0
		for i in range(open.size()):
			if open[i].f() < atual.f():
				atual = open[i]
				idx_atual = 1
			elif open[i].f() == atual.f() and open[i].h < atual.h:
				atual = open[i]
				idx_atual = 1
		open.remove_at(idx_atual)
		if atual.pos == fim:
			return _reconstruir_path(atual)
		var key:String = str(atual.pos.x) + "," + str(atual.pos.y)
		close[key] = atual
		var vizinhos:Array[Vector2i] = _vizinhos(atual.pos)
		for viz in vizinhos:
			var key_viz:String = str(viz.x) + "," + str(viz.y)
			if close.has(key_viz):
				continue
			var custo:int = _custo_mov(atual.pos, viz)
			var g_novo:int = atual.g + custo
			var no_exist:NoAStar = null
			for no in open:
				if no.pos == viz:
					no_exist = no
					break
			if no_exist == null:
				var h_novo:int = _heuristica_octogonal(viz, fim)
				var novo_no:NoAStar = NoAStar.new(viz, g_novo, h_novo, atual)
				open.append(novo_no)
			elif g_novo < no_exist.g:
				no_exist.atualizar_path(g_novo, atual)
	return []
	
func _chave_pontos(i: int, j: int) -> String:
	var a: int = min(i, j)
	var b: int = max(i, j)
	return str(a) + "," + str(b)

func _distant_entre_pontos(i:int, j:int) -> int:
	if i == j:
		return 0
	return _cache_distancias.get(_chave_pontos(i, j), INF_INT)

func _calc_distan_path(caminho: Array[Vector2]) -> int:
	if caminho.size() < 2:
		return 0
	var dist:int = 0
	for k in range(caminho.size() - 1):
		dist += int(caminho[k].distance_to(caminho[k + 1]))
	return dist

func _pre_calc_distancias() -> void:
	var total:int = pontos_interesse.size()
	for i in range(total):
		for j in range(i + 1, total):
			var chave:String = _chave_pontos(i, j)
			var path:Array[Vector2] = a_star_manual(pontos_interesse[i], pontos_interesse[j])
			var distant:int = _calc_distan_path(path)
			_cache_distancias[chave] = distant

func _algorit_guloso() -> Array[int]:
	var n:int = pontos_interesse.size()
	if n <= 1:
		return range(n)
	var nao_visitados:Array[int] = range(n)
	var ordem:Array[int] = []
	var atual:int = 0
	
	ordem.append(atual)
	nao_visitados.erase(atual)
	
	while nao_visitados.size() > 0:
		var melhor:int = nao_visitados[0]
		var menor_dist:int = _distant_entre_pontos(atual, melhor)
		for candidato in nao_visitados:
			var dist:int = _distant_entre_pontos(atual, candidato)
			if dist < menor_dist:
				menor_dist = dist
				melhor = candidato
		ordem.append(melhor)
		nao_visitados.erase(melhor)
		atual=melhor
	return ordem

func _gerar_caminho_completo(ordem:Array[int]) -> Array[Vector2]:
	var caminho_total:Array[Vector2] = []
	for i in range(ordem.size() - 1):
		var segmento:Array[Vector2] = a_star_manual(pontos_interesse[ordem[i]], pontos_interesse[ordem[i+1]])
		if segmento.is_empty():
			print("Erro: caminho vazio entre ", ordem[i], " e ", ordem[i + 1])
			continue
		if caminho_total.size() > 0:
			caminho_total.pop_back()
		caminho_total.append_array(segmento)
	return caminho_total

func _encontrar_ponto_mais_proximo(pos: Vector2) -> int:
	var melhor: int = 0
	var menor_dist: int = INF_INT
	for i in range(pontos_interesse.size()):
		var dist: int = int(pos.distance_to(pontos_interesse[i]))
		if dist < menor_dist:
			menor_dist = dist
			melhor = i
	return melhor

func _inic_rota() -> void:
	var ordem:Array[int] = _algorit_guloso()
	_pontos_restantes = ordem.slice(1)
	_caminho_atual = _gerar_caminho_completo(ordem)
	_indice_caminho = 0
	_visu
