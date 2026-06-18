extends Enemy
class_name Slime

func give_damage() -> int:
	return max(Dice.sum_rolls(2, 4) + atribute_mod("STR"), 1)
