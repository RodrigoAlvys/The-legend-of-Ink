extends CharacterBody2D

func interact():
	DialogueUI.start_dialogue([
		"O Amarelo se mudou recentemente pra vila, então ele ainda tá arrumando a loja.",
		"Quando tudo estiver em ordem, pode vir comprar o que for que ele vai vender"
	])
