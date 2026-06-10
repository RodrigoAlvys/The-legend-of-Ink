extends CharacterBody2D

@export var npc_id := "roxo"

func interact():
	match Gamestate.npc_dialogue_stage[npc_id]:
		0:
			DialogueUI.start_dialogue([
				"Ai... Como fui parar nessa caverna... agora têm esse monte de slime de tinta bloquando o caminho.",
				"ESPERA, você também é feito de tinta. Nem pense em chegar perto, sai daqui!"
			])
			Gamestate.npc_dialogue_stage[npc_id] = 1

		1:
			DialogueUI.start_dialogue([
				"Alguêm me ajuda por favor. Quero sair daqui."
			])
