extends CharacterBody2D

func interact():
	DialogueUI.start_dialogue([
		"Opa, o Vermelho te enviou? Ufa ainda bem.",
		"Os slimes tão começando a chegar perto demais da vila, então tô precisando ficar aqui de guarda.",
		"Derrote alguns deles pra mim vai. Talvez deixe meu trabalho mais fácil."
	])
