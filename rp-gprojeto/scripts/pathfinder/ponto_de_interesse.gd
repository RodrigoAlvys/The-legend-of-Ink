extends Area2D
class_name PontoDeInteresse

@export var pathfinder: Pathfinder
@export var tecla_coleta: Key = KEY_E

var _player_no_ponto: bool = false
var _indice: int = -1
var _registrado: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	await get_tree().process_frame
	
	if pathfinder:
		_registrar()

func _registrar():
	if _registrado:
		return
	
	_indice = pathfinder.adicionar_ponto(global_position)
	_registrado = true

func _on_body_entered(body):
	if body == pathfinder.player:
		_player_no_ponto = true

func _on_body_exited(body):
	if pathfinder and body == pathfinder.player:
		_player_no_ponto = false

func _input(event):
	if not _player_no_ponto:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == tecla_coleta:
			coletar()

func coletar():
	if _indice != -1 and pathfinder:
		pathfinder.remover_ponto(_indice)
		queue_free()
