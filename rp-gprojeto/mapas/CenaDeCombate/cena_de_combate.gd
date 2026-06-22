extends Node2D

@onready var combat_engine:=$CombateEngine
@onready var ui:=$UI/Control

func _ready() -> void:
	if Combat_Data.is_playable():
		combat_engine.combat_start(Combat_Data.fighters)

func test():
	pass
