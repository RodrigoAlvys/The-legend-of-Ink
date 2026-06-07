extends CharacterBody2D

func interact():
	DialogueUI.start_dialogue([
		"Olá, sou a fazendeira da vila.",
		"No momento ainda estou formando a plantação, mas quando estiver pronta você pode vir pegar comida"
	])
