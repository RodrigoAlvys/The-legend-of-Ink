extends CharacterBody2D

@export var npc_id := "ciano"

func interact():
	match Gamestate.npc_dialogue_stage[npc_id]:
		0:
			DialogueUI.start_dialogue([
				"Sei como o pessoal tá assustado com você sendo feito dessa mesma tinta que os monstros...",
				"Mas relaxa, pois eu, Ciano, Tô contigo."
			])
			Gamestate.npc_dialogue_stage[npc_id] = 1

		1:
			DialogueUI.start_dialogue([
				"O Amarelo se mudou recentemente pra vila, então ele ainda tá arrumando a loja.",
				"Quando tudo estiver em ordem, pode vir comprar o que for que ele vai vender... nem eu sei ainda o que é."
			])
