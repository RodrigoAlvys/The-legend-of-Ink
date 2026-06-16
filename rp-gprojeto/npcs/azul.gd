extends CharacterBody2D

@export var npc_id := "azul"

func interact():
	match Gamestate.npc_dialogue_stage[npc_id]:
		0:
			DialogueUI.start_dialogue([
				"...Oi, sou o Azul."
			])
			Gamestate.npc_dialogue_stage[npc_id] = 1

		1:
			DialogueUI.start_dialogue([
				"...Oi...",
				"Prefiro ficar sozinho, então por gentileza, poderia se retirar?"
			])
