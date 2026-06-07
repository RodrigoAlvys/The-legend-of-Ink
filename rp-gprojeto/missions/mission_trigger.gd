# MissionTrigger.gd
# Gatilho de missão para colocar num NPC ou numa zona do mapa.
# Quando o player está perto e aperta E (ação "interact"), inicia ou conclui a
# missão. NÃO depende de diálogo, quando o diálogo existir, ele
# pode chamar Game.missions.iniciar(...) no lugar disto.
# adiciona este script a um Area2D, com um CollisionShape2D
# filho marcando o alcance, e (opcional) um Sprite2D do NPC.

class_name MissionTrigger
extends Area2D

@export var missao_id: String = ""
@export var acao: String = "iniciar"   # "iniciar", "avancar" ou "concluir"
@export var uma_vez: bool = true
@export var automatico: bool = true    # true = dispara só de chegar perto (sem apertar E)

var _player_perto: bool = false
var _usado: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_perto = true
		if automatico:
			_disparar()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_perto = false

func _unhandled_input(event: InputEvent) -> void:
	if automatico:
		return                     # no modo automático o E não é necessário
	if not _player_perto:
		return
	if event.is_action_pressed("interact"):
		_disparar()

func _disparar() -> void:
	if _usado and uma_vez:
		return
	if Game.missions == null:
		return
	match acao:
		"concluir":
			Game.missions.concluir(missao_id)
		"avancar":
			Game.missions.avancar(missao_id)
		_:
			Game.missions.iniciar(missao_id)
	_usado = true
