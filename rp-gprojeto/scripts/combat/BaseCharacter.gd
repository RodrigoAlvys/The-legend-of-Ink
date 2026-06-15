#BaseCharacter
# Classe abstrata
extends Node2D
class_name BaseCharacter

const BASE_ATTRIBUTES:Array[String] = [
	"STR",
	"DEX",
	"CON",
	"ESP"
]
var _name:Array[String] = [""]
@export var fullname:String:
	get: return " ".join(_name)
	set(new):
		self._name = new.strip_edges().left(30).capitalize().split()
var first_name:String:
	get: return _name[0] if not self._name.is_empty() else ""
	set(new):
		if _name.is_empty():
			self._name = [""]
		new = new.strip_edges().capitalize().split()[0]
		var current_surname:String = " ".join(_name.slice(1))
		self.fullname = new + " " + current_surname
var surname:String = "":
	get: return " ".join(self._name.slice(1))
	set(new):
		if _name.is_empty():
			self._name = [""]
		new = new.strip_edges().capitalize()
		var current_first_name:String = _name[0]
		self.fullname = current_first_name + " " + new
		
# F = Feminino; M = Masculino; Não Binário = NB 
var _gender:String
@export_enum("Masculino", "Feminino", "Não Binário") var gender:String:
	get:
		if self._gender.split()[0] in ["M", "MASCULINO", "HOMEM", "MENINO"]:
			return "e"
		elif self._gender.split()[0] in ["F", "FEMININO", "MULHER", "MENINA"]:
			return "a"
		else:
			return "u"
	set(gen):
		self._gender = gen.strip_edges().to_upper()
var _level:int
@export_range(0, 10) var level:int = 0:
	get: return self._level
	set(novo): _level = max(0, min(10, novo))

# Atributos de 1 a 20 D&D vibes
@export_group("Atributos bases")
@export_range(1, 30) var STR:int = 10
var STR_mod:int = 0
@export_range(1, 30) var DEX:int = 10
var DEX_mod:int = 0
@export_range(1, 30) var CON:int = 10
var CON_mod:int = 0
@export_range(1, 30) var ESP:int = 10
var ESP_mod:int = 0

@export_group("Atributos produtos")
var _hp_max:int
@export_range(1, 999) var hp_max:int = 10:
	get: return self._hp_max
	set(new): self._hp_max = max(1, new)
var hp_max_mod:int
var _hp_current:int
@export var hp_current:int = 10:
	get: return self._hp_current
	set(new): self._hp_current = max(0, min(self.get_max_health(), new))
var _mp_max:int
@export_range(1, 999) var mp_max:int = 10:
	get: return self._mp_max
	set(new): self._mp_max = max(1, new)
var mp_max_mod:int
var _mp_current:int
@export var mp_current:int = 10:
	get: return self._mp_current
	set(new): self._mp_current = max(0, min(self.get_max_mana(), new))

# Inventário

func attack(ATR_base:String="STR") -> int:
	return generic_roll(ATR_base)
func give_damage(ATR_base:String="STR") -> int:
	return randi_range(1, 4) + randi_range(1, 4) + max(atribute_mod(ATR_base), 0)
func dodge() -> int:
	return generic_roll("DEX", false)
func defend():
	return atribute_mod("CON")*2 + self.level
func run():
	return randi_range(1, 100)
func take_damage(damage:int) -> void:
	var temp = self.hp_current - max(damage-self.get_CON(), 0)
	self.hp_current = temp
func atribute_mod(attr:String, mod:bool=true):
	attr.strip_edges().to_upper()
	var getters:Dictionary[String, Callable] = {
		"STR": self.get_STR,
		"DEX": self.get_DEX,
		"CON": self.get_CON,
		"ESP": self.get_ESP,
	}
	if not getters.has(attr):
		push_error("Atributo inválido: ", attr)
		return 0
	return floori(getters[attr].call(mod)/2.0)-5
func get_STR(mod:bool=true) -> int:
	return self.STR+self.STR_mod if mod else self.STR
func get_DEX(mod:bool=true) -> int:
	return self.DEX+self.DEX_mod if mod else self.DEX
func get_CON(mod:bool=true) -> int:
	return self.CON+self.CON_mod if mod else self.CON
func get_ESP(mod:bool=true) -> int:
	return self.ESP+self.ESP_mod if mod else self.ESP
func get_max_health(mod:bool=true) -> int:
	var hp:int = self.hp_max+self.hp_max_mod if mod else self.hp_max
	return max(1, hp)
func get_max_mana(mod:bool=true) -> int:
	var mp:int = self.mp_max+self.mp_max_mod if mod else self.mp_max
	return max(1, mp)
func estoy_muerto() -> bool:
	return true if self.hp_current<1 else false
func generic_roll(attr:String, prof_mod:bool=true, attr_mod:bool=true) -> int:
	var dice:int = randi_range(1, 10)
	var modifier:int = atribute_mod(attr, attr_mod)
	if prof_mod:
		modifier+=level
	return dice + modifier
