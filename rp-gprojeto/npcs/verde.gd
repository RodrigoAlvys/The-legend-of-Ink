extends CharacterBody2D

@export var npc_id := "verde"

func interact():
	match Gamestate.npc_dialogue_stage[npc_id]:
		0:
			DialogueUI.start_dialogue([
				"Olá, sou Verde, a fazendeira da vila.",
				"No momento ainda estou formando a plantação, mas quando estiver pronta você pode vir pegar comida."
			])
			Gamestate.npc_dialogue_stage[npc_id] = 1

		1:
			DialogueUI.start_dialogue([
				"Espero que o pessoal comece a se dar bem com você."
			])
