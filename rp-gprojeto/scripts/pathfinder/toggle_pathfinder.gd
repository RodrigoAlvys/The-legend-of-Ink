extends Node

@export var pathfinder: Pathfinder
@export var line2d: Line2D
@export var timer: Timer
@export var tecla_mostrar: Key = KEY_V

var _visivel: bool = true

func _ready():
	if line2d:
		_visivel = line2d.visible

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == tecla_mostrar:
			_visivel = not _visivel
			
			if line2d:
				line2d.visible = _visivel
			
			if _visivel:
				_ativar_recalculo()
			else:
				_desativar_recalculo()

func _ativar_recalculo():
	if timer and not timer.is_processing():
		timer.start()
	
	if pathfinder:
		pathfinder.recalcular_rota()

func _desativar_recalculo():
	if timer and timer.is_processing():
		timer.stop()
