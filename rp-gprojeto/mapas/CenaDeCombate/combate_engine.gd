extends Node2D

signal combat_end()

var fighters:Array[BaseCharacter] = []
var initiative:Initiative=null

func combat_start(fighters_:Array[BaseCharacter])->void:
	combat_end.emit()
	fighters=fighters_
