extends Node
class_name CombatData

var startable:bool=false
var fighters:Array[BaseCharacter]=[]
var prev_cene:String=""

func set_combat_data(cene:String, fighters_:Array[BaseCharacter]):
	prev_cene=cene
	fighters=fighters_
	is_playable()

func is_playable()->bool:
	if fighters.size()<2:
		startable=false
	for x in fighters:
		if x.playable:
			startable=true
	return startable

func clear()->void:
	startable=false
	fighters=[]
	prev_cene=""
