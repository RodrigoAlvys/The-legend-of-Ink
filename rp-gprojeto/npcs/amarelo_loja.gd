extends CharacterBody2D

func interact():
	DialogueUI.start_dialogue([
		"Opa, mais um cliente?",
		"Bom, infelizmente ainda estou arrumando minha loja, mas quando estiver tudo em ordem, quero te ver mais vezes por aqui hein."
	])
