extends Node2D

@onready var Player:BaseCharacter = $Status
var enemies:Array[BaseCharacter] = []

var rounds:int = 0

func _ready() -> void:
	if Player.estoy_muerto():
		pass
func combat_loop(player:BaseCharacter, enemies:Array[BaseCharacter]) -> int:
	"""
	return:  0 - Perdeu a batalha
			 1 - Ganhou a batalha
			 2 - Fugiu da batalha
			-1 - Error
	"""
	var resul:int = -1
	var initiative:Array[Array]
	if player.estoy_muerto():
		push_error("Começou loop de combate com o Player: %s morto", player.first_name)
		return -1
	initiative.append([player.initiative(), player])
	for x in enemies:
		if x.estoy_muerto():
			push_warning("Começou loop de combate com o inimigo: %s morto", x.first_name)
		else:
			initiative.append([x.initiative(), x])
	if initiative.size()<2:
		push_error("Error, Não é possível fazer combate sozinho")
		return -1
	initiative.sort_custom(func(a, b): return a[0]>b[0])
	while not player.estoy_muerto() and initiative.size()>1:
		rounds+=1
		print("Round: %i", round)
	return resul
