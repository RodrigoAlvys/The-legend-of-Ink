extends NPC
class_name Slime

func free() -> void:
	self.race = "Slime"
	super._ready()

func give_damage() -> int:
	return max(Dice.sum_rolls(2, 4) + atribute_mod("ESP"), 1)
