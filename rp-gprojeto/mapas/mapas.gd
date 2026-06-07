extends Node2D

func _ready():
	call_deferred("_spawn")

func _spawn():
	var player = get_tree().get_first_node_in_group("player")

	for node in get_tree().get_nodes_in_group("spawn_points"):
		if String(node.spawn_id) == String(Game.spawn_temp):
			player.global_position = node.global_position
			break

	Game.spawn_temp = ""

	await Fade.fade_in(0.25)
