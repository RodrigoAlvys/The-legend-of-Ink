extends Node2D

@export var tilemap: TileMapLayer
@export_flags_2d_navigation var nav_mask: int = 1
@export var pontos_interesse: Array[Vector2]
@export var player: CharacterBody2D
@export var line: Line2D
@export var timer: Timer

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
	return true
