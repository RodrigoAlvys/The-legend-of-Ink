extends CharacterBody2D

func interact():
	DialogueUI.start_dialogue([
		"Olá jovem, eu sou Cinza, o ancião da vila.",
		"Vejo que está perdido e sem para onde ir, então vou ter dar uma ajuda",
		"Ajude o pessoal aqui da vila, e lhe daremos um local para ficar até encontrar seu rumo."
	])
