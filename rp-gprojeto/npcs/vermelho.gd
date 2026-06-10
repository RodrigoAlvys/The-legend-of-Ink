extends CharacterBody2D


@export var npc_id := "vermelho"

func interact():
	match Gamestate.npc_dialogue_stage[npc_id]:
		0:
			DialogueUI.start_dialogue([
				"Você derrotou o slime de tinta na caverna? Eu estava prestes a fazer isso.",
				"Encontrou Roxo lá dentro? Ele devia estar em algum lugar por lá...",
				"Enfim, vejo que possui habilidades de combate. Vá dar uma ajuda ao Laranja enquanto eu converso com o Cinza para ver o que fazemos sobre você.",
				"Ele está do lado de fora da vila, para o oeste."
			])
			Game.missions.iniciar("gosma")
			Gamestate.npc_dialogue_stage[npc_id] = 1

		1:
			DialogueUI.start_dialogue([
				"Espero que o pessoal comece a se dar bem com você."
			])
