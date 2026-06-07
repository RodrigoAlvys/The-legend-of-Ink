extends Area2D

var ativado := false

@export var destino_mapa: String
@export var spawn_id_saida: StringName

# Missão que esta saída faz avançar automaticamente quando o jogador chega aqui.
@export var missao_id: String = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if ativado:
		return

	if not body.is_in_group("player"):
		return

	ativado = true

	# chegou na saída => a missão avança/conclui sozinha (sem clicar no menu)
	if missao_id != "" and Game.missions != null:
		Game.missions.avancar(missao_id)

	Game.spawn_temp = spawn_id_saida
	await Fade.fade_out(0.3)
	get_tree().change_scene_to_file(destino_mapa)
