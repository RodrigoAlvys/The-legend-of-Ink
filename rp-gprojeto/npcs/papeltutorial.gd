extends Area2D

func interact():
	DialogueUI.start_dialogue([
		"Mova com wasd ou setas, segure shift para correr.\nE para interagir, I para abrir o inventário, G para coletar item do chão, J para abrir o menu de missões, V para ativar/desativar o pathfind."
	])
