#BaseCharacter
# Classe abstrata
extends Node2D
class_name BaseCharacter

signal death(character:BaseCharacter)
signal change_hp(character:BaseCharacter, new:int, old:int)
signal change_mp(character:BaseCharacter, new:int, old:int)
signal change_hp_max(character:BaseCharacter, new:int, old:int)
signal change_mp_max(character:BaseCharacter, new:int, old:int)

var _name:Array[String] = [""]
@export var fullname:String:
	get: return get_fullname()
	set(new): set_fullname(new)
var first_name:String:
	get: return get_first_name()
	set(new): set_first_name(new)
var surname:String = "":
	get: return get_surname()
	set(new): set_surname(new)
var _race:String
@export var race:String:
	get: return _race
	set(new): _race=new.strip_edges().capitalize()
# F = Feminino; M = Masculino; Não Binário = NB 
var _gender:String
@export_enum("Masculino", "Feminino", "Não Binário") var gender:String:
	get: return get_gender()
	set(gen): set_gender(gen)
var _level:int
@export_range(0, 10) var level:int = 0:
	get: return get_level()
	set(new): set_level(new)

# Atributos de 1 a 20 D&D vibes
@export_group("Atributos bases")
var _STR:int
@export_range(1, 30) var STR:int = 10:
	get: return get_STR()
	set(new): set_STR(new)
var STR_mod:int = 0
var STR_temp:int = 0
var _DEX:int
@export_range(1, 30) var DEX:int = 10:
	get: return get_DEX()
	set(new): set_DEX(new)
var DEX_mod:int = 0
var DEX_temp:int = 0
var _CON:int
@export_range(1, 30) var CON:int = 10:
	get: return get_CON()
	set(new): set_CON(new)
var CON_mod:int = 0
var CON_temp:int = 0
var _ESP:int
@export_range(1, 30) var ESP:int = 10:
	get: return get_ESP()
	set(new): set_ESP(new)
var ESP_mod:int = 0
var ESP_temp:int = 0

@export_group("Vida e Mana")
var _hp_max:int
@export_range(1, 999) var hp_max:int = 10:
	get: return get_hp_max()
	set(new): push_warning("HpMAX é um atributo produto, portanto não pode ser definida")
var _hp_max_mod:int=0
var hp_max_mod:int:
	get: return _hp_max_mod
	set(new):
		_hp_max_mod=new
		set_hp_max()
var _hp_max_temp:int=0
var hp_max_temp:int:
	get: return hp_max_temp
	set(new):
		_hp_max_temp=new
		set_hp_max()
var _hp_current:int=0
@export var hp_current:int:
	get: return get_hp_current()
	set(new): set_hp_current(new)
var _mp_max:int
@export_range(1, 999) var mp_max:int = 10:
	get: return get_mp_max()
	set(new): push_warning("MpMAX é um atributo produto, portanto não pode ser definida")
var _mp_max_mod:int=0
var mp_max_mod:int:
	get: return _mp_max_mod
	set(new):
		_mp_max=new
		set_mp_max()
var _mp_max_temp:int=0
var mp_max_temp:int:
	get: return _mp_max_temp
	set(new):
		_mp_max_temp=new
		set_mp_max()
var _mp_current:int
@export var mp_current:int:
	get: return get_mp_current()
	set(new): set_mp_current(new)

var _accuracy:int
var accuracy_mod:int
var accuracy_temp:int
var accuracy:int:
	get: return get_accuracy()
	set(new): push_warning("Accuracy é um atributo produto, portanto não pode ser definida")
var _initiative:int
var initiative_mod:int
var initiative_temp:int
var initiative_bonus:int:
	get: return get_initiative()
	set(new): push_warning("Accuracy é um atributo produto, portanto não pode ser definida")
var _resistance:int
var resistance_mod:int
var resistance_temp:int
var resistance:int:
	get: return get_resistance()
	set(new): push_warning("Accuracy é um atributo produto, portanto não pode ser definida")
	
var armor:Item=null
var weapon:Item=null
var accesory1:Item=null
var accesory2:Item=null

func test_initiative() -> int:
	return generic_roll("DEX")
func attack() -> int:
	return Dice.d10()+accuracy
func give_damage() -> int:
	if weapon:
		pass
	return max(Dice.d4() + atribute_mod("STR"), 1)
func dodge() -> int:
	return generic_roll("DEX")
func defend():
	resistance_temp=atribute_mod("CON") + self.level
func run():
	return Dice.d100()
func take_damage(damage:int) -> void:
	self.hp_current -= max(damage-resistance, 0)
func take_healing(heal:int) -> void:
	self.hp_current += max(heal, 0)
func atribute_mod(attr:String, temp:bool=true, mod:bool=true):
	attr.strip_edges().to_upper()
	var getters:Dictionary[String, Callable] = {
		"STR": self.get_STR.bind(temp, mod),
		"DEX": self.get_DEX.bind(temp, mod),
		"CON": self.get_CON.bind(temp, mod),
		"ESP": self.get_ESP.bind(temp, mod),
	}
	if not getters.has(attr):
		push_error("Atributo inválido: ", attr)
		return 0
	return floori(getters[attr].call()/2.0)-5
func estoy_muerto() -> bool:
	if hp_current<1:
		death.emit(self)
		return true
	return false
func generic_roll(attr:String, prof_mod:bool=false, attr_mod:bool=true, temp_mod:bool=true) -> int:
	var modifier:int = atribute_mod(attr, temp_mod, attr_mod)
	if prof_mod:
		modifier+=level
	return Dice.d10() + modifier
	
# resets

func reset_temp()->void:
	CON_temp=0
	DEX_temp=0
	ESP_temp=0
	STR_temp=0
	hp_max_temp=0
	mp_max_temp=0
	accuracy_temp=0
	initiative_temp=0
	resistance_temp=0
func set_all_derivative()->void:
	set_accuracy()
	set_hp_max()
	set_mp_max()
	set_resistance()
	set_initiative()
#	Gets e Sets

func get_fullname()->String: 
	return " ".join(_name)
func set_fullname(new:String)->void:
	self._name = new.strip_edges().left(30).capitalize().split()
func get_first_name()->String:
	return _name[0] if not self._name.is_empty() else ""
func set_first_name(new:String):
	if _name.is_empty():
		self._name = [""]
	new = new.strip_edges().capitalize().split()[0]
	var current_surname:String = " ".join(_name.slice(1))
	self.fullname = new + " " + current_surname
func get_surname()->String:
	return " ".join(self._name.slice(1))
func set_surname(new)->void:
	if _name.is_empty():
		self._name = [""]
	new = new.strip_edges().capitalize()
	var current_first_name:String = _name[0]
	self.fullname = current_first_name + " " + new
func get_gender()->String:
		if self._gender.split()[0] in ["M", "MASCULINO", "HOMEM", "MENINO"]:
			return "e"
		elif self._gender.split()[0] in ["F", "FEMININO", "MULHER", "MENINA"]:
			return "a"
		else:
			return "u"
func set_gender(gen)->void:
	self._gender = gen.strip_edges().to_upper()
func get_level()->int:
	return self._level
func set_level(novo)->void:
	_level = max(0, min(10, novo))
	set_all_derivative()
# Atributos de 1 a 20 D&D vibes
func get_STR(temp:bool=true, mod:bool=true)->int:
	var resul:int=_STR
	if temp:
		resul+=STR_temp
	if mod:
		resul+=STR_mod
	return resul
func set_STR(new):
	_STR = max(1, min(30, new))
func get_DEX(temp:bool=true, mod:bool=true)->int:
	var resul:int=_DEX
	if temp:
		resul+=DEX_temp
	if mod:
		resul+=DEX_mod
	return resul
func set_DEX(new)->void:
	_DEX = max(1, min(30, new))
	set_accuracy()
func get_CON(temp:bool=true, mod:bool=true)->int:
	var resul:int=_CON
	if temp:
		resul+=CON_temp
	if mod:
		resul+=CON_mod
	return resul
func set_CON(new)->void:
	_CON = max(1, min(30, new))
	self.set_hp_max()
func get_ESP(temp:bool=true, mod:bool=true)->int:
	var resul:int=_ESP
	if temp:
		resul+=ESP_temp
	if mod:
		resul+=ESP_mod
	return resul
func set_ESP(new)->void:
	_ESP = max(1, min(30, new))
	self.set_mp_max()
func get_hp_max(temp:bool=true, mod:bool=true)->int:
	var resul:int=_hp_max
	if temp:
		resul+=hp_max_temp
	if mod:
		resul+=hp_max_mod
	return max(resul, 1)
func set_hp_max() -> void:
	var old:int = get_hp_max()
	var new:int = self.get_CON()+floori(self.level*self.get_CON()/2.0)
	change_hp_max.emit(self, new, old)
	_hp_max=new
func get_hp_current()->int:
	return self._hp_current
func set_hp_current(value)->void:
	var old:int = self.hp_current
	var new:int = max(0, min(self.get_hp_max(), value))
	change_hp.emit(self, new, old)
	self._hp_current = new
	estoy_muerto()
func get_mp_max(temp:bool=true, mod:bool=true)->int:
	var resul:int=mp_max
	if temp:
		resul+=mp_max_temp
	if mod:
		resul+=mp_max_mod
	return max(resul, 1)
func set_mp_max() -> void:
	var old:int = get_mp_max()
	var new:int = floori(self.get_ESP()/2.0) + floori(self.level*self.get_ESP()/4.0)
	change_mp_max.emit(self, new, old)
	self._mp_max = new
func get_mp_current()->int:
	return self._mp_current
func set_mp_current(value)->void:
	var old:int = self.mp_current
	var new:int = max(0, min(self.get_mp_max(), value))
	change_mp.emit(self, new, old)
	self._mp_current = new
func get_accuracy(temp:bool=true, mod:bool=true)->int:
	var resul:int=_accuracy
	if temp:
		resul+=accuracy_temp
	if mod:
		resul+=accuracy_mod
	return resul
func set_accuracy()->void:
	_accuracy=atribute_mod("DEX")+get_level()
func get_initiative(temp:bool=true, mod:bool=true)->int:
	var resul:int=_initiative
	if temp:
		resul+=initiative_temp
	if mod:
		resul+=initiative_mod
	return resul
func set_initiative()->void:
	_initiative=atribute_mod("DEX")
func get_resistance(temp:bool=true, mod:bool=true)->int:
	var resul:int=_resistance
	if temp:
		resul+=resistance_temp
	if mod:
		resul+=resistance_mod
	return resul
func set_resistance()->void:
	_resistance=max(atribute_mod("CON"), 0)
