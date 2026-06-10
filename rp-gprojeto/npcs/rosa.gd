extends CharacterBody2D

@export var npc_id := "rosa"

func interact():
	match Gamestate.npc_dialogue_stage[npc_id]:
		0:
			DialogueUI.start_dialogue([
				"EI, você é feito de tinta que nem esses bicho? Nem pense em chegar perto.",
				"Não tenho experiencia lutando como o Vermelho ou Laranja, mas se você tentar qualquer coisa..."
			])
			Gamestate.npc_dialogue_stage[npc_id] = 1

		1:
			DialogueUI.start_dialogue([
				"Essa loja tá vazia demais pro meu gosto."
			])
