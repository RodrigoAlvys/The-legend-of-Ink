extends Enemy

func give_damage() -> int:
	return max(Dice.sum_rolls(2, 4) + atribute_mod("STR"), 1)

func _init() -> void:
	self.fullname="Slime Meloso"
	self.race="Slime"
	self.gender="M"
	self.STR=11
	self.DEX=8
	self.CON=13
	self.ESP=13
	self.level=1
