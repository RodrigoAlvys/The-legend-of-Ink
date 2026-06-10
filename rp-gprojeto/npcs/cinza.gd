extends CharacterBody2D

@export var npc_id := "cinza"

func interact():
	match Gamestate.npc_dialogue_stage[npc_id]:
		0:
			DialogueUI.start_dialogue([
				"Olá jovem, eu sou Cinza, o ancião da vila.",
				"Vejo que está perdido e sem para onde ir, então vou ter dar uma ajudinha.",
				"Ajude o pessoal aqui da vila, e lhe daremos um local para ficar até encontrar seu rumo."
			])
			Gamestate.npc_dialogue_stage[npc_id] = 1

		1:
			DialogueUI.start_dialogue([
				"Tenho certeza que todos da vila irão lhe dar as boas vindas se lhe verem ajudando a todos daqui."
			])
