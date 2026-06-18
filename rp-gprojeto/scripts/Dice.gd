extends RefCounted
class_name Dice

static func d2()->int:
	return randi_range(1, 2)

static func d4()->int:
	return randi_range(1, 4)

static func d6()->int:
	return randi_range(1, 6)

static func d8()->int:
	return randi_range(1, 8)

static func d10()->int:
	return randi_range(1, 10)
	
static func d12()->int:
	return randi_range(1, 12)
	
static func d20()->int:
	return randi_range(1, 20)
	
static func d100()->int:
	return randi_range(1, 100)
	
static func multi_roll(num:int, sides:int)->Array[int]:
	var resul:Array[int]=[]
	var dices:Dictionary[int, Callable] = {
		2:d2,
		4:d4,
		6:d6,
		8:d8,
		10:d10,
		12:d12,
		20:d20,
		100:d100
	}
	if not dices.has(sides):
		push_warning("Esse tipo de dado não existe ou não é implementado")
	elif num<1:
		push_warning("Não é possível rodar 0 ou -3 dados, seu safado")
	else:
		for x in num:
			resul.append(dices[sides].call())
	return resul

static func sum_rolls(num:int, sides:int)->int:
	var rolls:Array[int]=multi_roll(num, sides)
	if not rolls:
		return 0
	if rolls.size()==1:
		return rolls[0]
	return rolls.reduce(func(a, b): return a+b, 0)
	
