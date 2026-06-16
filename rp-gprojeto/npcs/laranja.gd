extends CharacterBody2D

@export var npc_id := "laranja"

func interact():
	match Gamestate.npc_dialogue_stage[npc_id]:
		0:
			DialogueUI.start_dialogue([
				"Opa, o Vermelho te enviou? Ufa ainda bem.",
				"Os slimes tão começando a chegar perto demais da vila, então tô precisando ficar aqui de guarda.",
				"Derrote alguns deles pra mim vai. Talvez deixe meu trabalho mais fácil."
			])
			Gamestate.npc_dialogue_stage[npc_id] = 1

		1:
			DialogueUI.start_dialogue([
				"Aliás, esqueci de me apresentar. Sou Laranja, o lutador da vila.",
				"Pode deixar a segurança da vila comigo e com o Vermelho."
			])
			Gamestate.npc_dialogue_stage[npc_id] = 2
			
		2:
			DialogueUI.start_dialogue([
				"Pode deixar a segurança da vila comigo e com o Vermelho."
			])
