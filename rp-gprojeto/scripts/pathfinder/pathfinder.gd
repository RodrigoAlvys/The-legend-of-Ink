extends Node2D
class_name Pathfinder

@export var tilemap: TileMapLayer
@export_flags_2d_navigation var nav_mask: int = 1
@export var player: CharacterBody2D

const CUSTO_ORTOGONAL: int = 10
const CUSTO_DIAGONAL: int = 14
const INF_INT: int = 9999999999

signal caminho_atualizado(caminho: Array[Vector2])
signal ponto_removido(indice: int, posicao: Vector2)
signal missao_completa()

var _grid_size_x: int = 0
var _grid_size_y: int = 0
var _navegavel: Array[Array] = []
var _cell_size: Vector2

var pontos_interesse: Array[Vector2] = []
var _pontos_removidos: Array[int] = []
var _pontos_restantes: Array[int] = []
var _caminho_atual: Array[Vector2] = []
var _indice_caminho: int = 0
var _ativo: bool = true
var _precisa_iniciar: bool = true

var _cache_distancias: Dictionary = {}
var _cache_valido: bool = false

func _ready() -> void:
	var layer_mask: int = int(log(nav_mask) / log(2))
	if not _conf_grid(layer_mask):
		return

func adicionar_ponto(posicao: Vector2) -> int:
	pontos_interesse.append(posicao)
	var novo_indice = pontos_interesse.size() - 1
	_cache_valido = false
	
	if _precisa_iniciar and pontos_interesse.size() > 0:
		_precisa_iniciar = false
		call_deferred("iniciar")
	
	return novo_indice

func iniciar() -> void:
	if pontos_interesse.is_empty():
		return
	
	_cache_valido = false
	_pre_calc_distancias()
	_cache_valido = true
	_inic_rota()

func recalcular_rota() -> void:
	if player and _ativo and not pontos_interesse.is_empty():
		_recalcular_rota_apartir(player.global_position)

func remover_ponto(indice: int) -> void:
	if indice < 0 or indice >= pontos_interesse.size():
		return
	
	if indice in _pontos_removidos:
		return
	
	_pontos_removidos.append(indice)
	ponto_removido.emit(indice, pontos_interesse[indice])
	
	_recalcular_apos_remocao()

func remover_ponto_por_posicao(posicao: Vector2, tolerancia: float = 50.0) -> bool:
	for i in range(pontos_interesse.size()):
		if i in _pontos_removidos:
			continue
		if pontos_interesse[i].distance_to(posicao) <= tolerancia:
			remover_ponto(i)
			return true
	return false

func get_pontos_restantes() -> Array[Vector2]:
	var restantes: Array[Vector2] = []
	for i in range(pontos_interesse.size()):
		if i not in _pontos_removidos:
			restantes.append(pontos_interesse[i])
	return restantes

func get_caminho() -> Array[Vector2]:
	return _caminho_atual.duplicate()


func _conf_grid(layer_mask: int) -> bool:
	var rect = tilemap.get_used_rect()
	
	if rect.size.x == 0 or rect.size.y == 0:
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
			
			var nav_polygon = tile_data.get_navigation_polygon(layer_mask)
			_navegavel[y][x] = nav_polygon != null
	
	return true

func _mundo_to_grid(pos_mundo: Vector2) -> Vector2i:
	var rect = tilemap.get_used_rect()
	var cell = tilemap.local_to_map(pos_mundo)
	return Vector2i(cell.x - rect.position.x, cell.y - rect.position.y)

func _grid_to_mundo(pos_grid: Vector2i) -> Vector2:
	var rect = tilemap.get_used_rect()
	var cell_mundo = Vector2i(rect.position.x + pos_grid.x, rect.position.y + pos_grid.y)
	return tilemap.map_to_local(cell_mundo)

func _is_navegavel(pos_grid: Vector2i) -> bool:
	if pos_grid.x < 0 or pos_grid.x >= _grid_size_x:
		return false
	if pos_grid.y < 0 or pos_grid.y >= _grid_size_y:
		return false
	return _navegavel[pos_grid.y][pos_grid.x]

func _heuristica_octogonal(pos: Vector2i, goal: Vector2i) -> int:
	var dx = abs(pos.x - goal.x)
	var dy = abs(pos.y - goal.y)
	return min(dx, dy) * CUSTO_DIAGONAL + abs(dx - dy) * CUSTO_ORTOGONAL

func _pode_diagonal(de: Vector2i, para: Vector2i) -> bool:
	var dx = para.x - de.x
	var dy = para.y - de.y
	if abs(dx) != 1 or abs(dy) != 1:
		return true
	var passo_horizontal = Vector2i(de.x + dx, de.y)
	var passo_vertical = Vector2i(de.x, de.y + dy)
	return _is_navegavel(passo_horizontal) and _is_navegavel(passo_vertical)

func _vizinhos(pos: Vector2i) -> Array[Vector2i]:
	var vizinhos: Array[Vector2i] = []
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var viz = Vector2i(pos.x + dx, pos.y + dy)
			if viz.x < 0 or viz.x >= _grid_size_x or viz.y < 0 or viz.y >= _grid_size_y:
				continue
			if not _is_navegavel(viz):
				continue
			if abs(dx) == 1 and abs(dy) == 1:
				if not _pode_diagonal(pos, viz):
					continue
			vizinhos.append(viz)
	return vizinhos

func _custo_mov(de: Vector2i, para: Vector2i) -> int:
	if abs(de.x - para.x) == 1 and abs(de.y - para.y) == 1:
		return CUSTO_DIAGONAL
	return CUSTO_ORTOGONAL

func _reconstruir_path(no_final) -> Array[Vector2]:
	var caminho_grid: Array[Vector2i] = []
	var atual = no_final
	
	while atual != null:
		caminho_grid.append(atual.pos)
		atual = atual.parent
	
	caminho_grid.reverse()
	
	var caminho_mundo: Array[Vector2] = []
	for pos_grid in caminho_grid:
		caminho_mundo.append(_grid_to_mundo(pos_grid))
	return caminho_mundo

func a_star_manual(inic_mundo: Vector2, fim_mundo: Vector2) -> Array[Vector2]:
	var inic = _mundo_to_grid(inic_mundo)
	var fim = _mundo_to_grid(fim_mundo)
	
	if not _is_navegavel(inic) or not _is_navegavel(fim):
		return []
	
	var open: Array = []
	var close: Dictionary = {}
	
	var h_inic = _heuristica_octogonal(inic, fim)
	var no_inic = NoAStar.new(inic, 0, h_inic)
	open.append(no_inic)
	
	while open.size() > 0:
		var atual = open[0]
		var idx_atual = 0
		for i in range(open.size()):
			if open[i].f() < atual.f():
				atual = open[i]
				idx_atual = i
			elif open[i].f() == atual.f() and open[i].h < atual.h:
				atual = open[i]
				idx_atual = i
		open.remove_at(idx_atual)
		
		if atual.pos == fim:
			return _reconstruir_path(atual)
		
		var key = str(atual.pos.x) + "," + str(atual.pos.y)
		close[key] = atual
		
		for viz in _vizinhos(atual.pos):
			var key_viz = str(viz.x) + "," + str(viz.y)
			if close.has(key_viz):
				continue
			
			var g_novo = atual.g + _custo_mov(atual.pos, viz)
			var no_exist = null
			for no in open:
				if no.pos == viz:
					no_exist = no
					break
			
			if no_exist == null:
				var h_novo = _heuristica_octogonal(viz, fim)
				var novo_no = NoAStar.new(viz, g_novo, h_novo, atual)
				open.append(novo_no)
			elif g_novo < no_exist.g:
				no_exist.atualizar_path(g_novo, atual)
	
	return []

func _chave_pontos(i: int, j: int) -> String:
	var a = min(i, j)
	var b = max(i, j)
	return str(a) + "," + str(b)

func _distancia_entre_pontos(i: int, j: int) -> int:
	if i == j:
		return 0
	if i < 0 or j < 0:
		return INF_INT
	if i >= pontos_interesse.size() or j >= pontos_interesse.size():
		return INF_INT
	var chave = _chave_pontos(i, j)
	return _cache_distancias.get(chave, INF_INT)

func _calc_distancia_caminho(caminho: Array[Vector2]) -> int:
	if caminho.size() < 2:
		return 0
	var dist = 0
	for k in range(caminho.size() - 1):
		dist += int(caminho[k].distance_to(caminho[k + 1]))
	return dist

func _pre_calc_distancias() -> void:
	if _cache_valido:
		return
	
	var total = pontos_interesse.size()
	
	for i in range(total):
		for j in range(i + 1, total):
			if i in _pontos_removidos or j in _pontos_removidos:
				continue
			var chave = _chave_pontos(i, j)
			var path = a_star_manual(pontos_interesse[i], pontos_interesse[j])
			var dist = _calc_distancia_caminho(path)
			_cache_distancias[chave] = dist

func _algoritmo_guloso() -> Array[int]:
	var ativos: Array[int] = []
	for i in range(pontos_interesse.size()):
		if i not in _pontos_removidos:
			ativos.append(i)
	
	if ativos.size() <= 1:
		return ativos
	
	var ordem: Array[int] = []
	var atual = ativos[0]
	ordem.append(atual)
	ativos.erase(atual)
	
	while ativos.size() > 0:
		var melhor = ativos[0]
		var menor_dist = _distancia_entre_pontos(atual, melhor)
		for candidato in ativos:
			var dist = _distancia_entre_pontos(atual, candidato)
			if dist < menor_dist:
				menor_dist = dist
				melhor = candidato
		ordem.append(melhor)
		ativos.erase(melhor)
		atual = melhor
	
	return ordem

func _gerar_caminho_completo(ordem: Array[int]) -> Array[Vector2]:
	var caminho_total: Array[Vector2] = []
	for i in range(ordem.size() - 1):
		var segmento = a_star_manual(pontos_interesse[ordem[i]], pontos_interesse[ordem[i + 1]])
		if segmento.is_empty():
			continue
		if caminho_total.size() > 0:
			caminho_total.pop_back()
		caminho_total.append_array(segmento)
	return caminho_total

func _inic_rota() -> void:
	if pontos_interesse.is_empty():
		return
	
	var ordem = _algoritmo_guloso()
	_pontos_restantes = ordem.slice(1)
	_caminho_atual = _gerar_caminho_completo(ordem)
	_indice_caminho = 0
	caminho_atualizado.emit(_caminho_atual)

func _recalcular_apos_remocao() -> void:
	_pontos_restantes.clear()
	for i in range(pontos_interesse.size()):
		if i not in _pontos_removidos:
			_pontos_restantes.append(i)
	
	if _pontos_restantes.is_empty():
		_ativo = false
		_caminho_atual = []
		caminho_atualizado.emit(_caminho_atual)
		missao_completa.emit()
		return
	
	_cache_valido = false
	_pre_calc_distancias()
	_cache_valido = true
	_inic_rota()

func _encontrar_ponto_mais_proximo(pos: Vector2) -> int:
	var melhor = -1
	var menor_dist = INF_INT
	for i in range(pontos_interesse.size()):
		if i in _pontos_removidos:
			continue
		var dist = int(pos.distance_to(pontos_interesse[i]))
		if dist < menor_dist:
			menor_dist = dist
			melhor = i
	return melhor

func _reordenar_pontos_apartir(pontos: Array[int], inicio: int) -> Array[int]:
	var nao_visitados: Array[int] = []
	for i in range(pontos.size()):
		nao_visitados.append(pontos[i])
	
	var ordem: Array[int] = []
	ordem.append(inicio)
	
	var idx_remover = -1
	for i in range(nao_visitados.size()):
		if nao_visitados[i] == inicio:
			idx_remover = i
			break
	if idx_remover != -1:
		nao_visitados.remove_at(idx_remover)
	
	var atual: int = inicio
	
	while nao_visitados.size() > 0:
		var melhor: int = nao_visitados[0]
		var menor_dist: int = _distancia_entre_pontos(atual, melhor)
		
		for i in range(nao_visitados.size()):
			var dist: int = _distancia_entre_pontos(atual, nao_visitados[i])
			if dist < menor_dist:
				menor_dist = dist
				melhor = nao_visitados[i]
		
		ordem.append(melhor)
		
		for i in range(nao_visitados.size()):
			if nao_visitados[i] == melhor:
				nao_visitados.remove_at(i)
				break
		
		atual = melhor
	
	return ordem

func _recalcular_rota_apartir(pos_jogador: Vector2) -> void:
	if not _ativo:
		return
	
	if pontos_interesse.is_empty():
		return
	
	var idx_mais_proximo = _encontrar_ponto_mais_proximo(pos_jogador)
	if idx_mais_proximo == -1:
		return
	
	var pontos_restantes: Array[int] = []
	for i in range(pontos_interesse.size()):
		if i not in _pontos_removidos:
			pontos_restantes.append(i)
	
	if pontos_restantes.is_empty():
		return
	
	var ordem: Array[int] = _reordenar_pontos_apartir(pontos_restantes, idx_mais_proximo)
	
	if ordem.is_empty():
		return
	
	var caminho_total: Array[Vector2] = a_star_manual(pos_jogador, pontos_interesse[ordem[0]])
	
	for i in range(ordem.size() - 1):
		var seg: Array[Vector2] = a_star_manual(pontos_interesse[ordem[i]], pontos_interesse[ordem[i + 1]])
		if seg.size() > 0:
			if caminho_total.size() > 0:
				caminho_total.pop_back()
			caminho_total.append_array(seg)
	
	_caminho_atual = caminho_total
	_indice_caminho = 0
	
	_pontos_restantes = []
	for i in range(1, ordem.size()):
		_pontos_restantes.append(ordem[i])
	
	caminho_atualizado.emit(_caminho_atual)
