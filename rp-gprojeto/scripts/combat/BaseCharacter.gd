#BaseCharacter
# Classe abstrata
extends Node
class_name BaseCharacter

signal death(character:BaseCharacter)
signal change_hp(character:BaseCharacter, new:int, old:int)
signal change_mp(character:BaseCharacter, new:int, old:int)
signal change_hp_max(character:BaseCharacter, new:int, old:int)
signal change_mp_max(character:BaseCharacter, new:int, old:int)
signal change_temp(character:BaseCharacter, attr:String, new:int, old:int)
signal change_mod(character:BaseCharacter, attr:String, new:int, old:int)
signal change_derivative(character:BaseCharacter)
signal change_role(character:BaseCharacter, role:Enum.ROLE)

const ATTRIBUTES:PackedStringArray = [
	"STR",
	"DEX",
	"CON",
	"ESP",
	"HP",
	"MP",
	"ACCURACY",
	"RESISTANCE",
	"INITIATIVE",
	"DODGE"
]

var _playable:bool=false
var _hostile:bool=false
var _friendly:bool=false
var _role:Enum.ROLE
var role:Enum.ROLE:
	get: return get_role()
	set(new): set_role(new)
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
var _DEX:int
@export_range(1, 30) var DEX:int = 10:
	get: return get_DEX()
	set(new): set_DEX(new)
var _CON:int
@export_range(1, 30) var CON:int = 10:
	get: return get_CON()
	set(new): set_CON(new)
var _ESP:int
@export_range(1, 30) var ESP:int = 10:
	get: return get_ESP()
	set(new): set_ESP(new)

@export_group("Vida e Mana")
var _hp_max:int
@export_range(1, 999) var hp_max:int = 10:
	get: return get_hp_max()
	set(new): push_warning("HpMAX é um atributo produto, portanto não pode ser definida")
var _hp_current:int=0
@export var hp_current:int:
	get: return get_hp_current()
	set(new): set_hp_current(new)
var _mp_max:int
@export_range(1, 999) var mp_max:int = 10:
	get: return get_mp_max()
	set(new): push_warning("MpMAX é um atributo produto, portanto não pode ser definida")

var _mp_current:int
@export var mp_current:int:
	get: return get_mp_current()
	set(new): set_mp_current(new)

var _accuracy:int
var accuracy:int:
	get: return get_accuracy()
	set(new): push_warning("Accuracy é um atributo produto, portanto não pode ser definida")
var _initiative:int
var initiative_bonus:int:
	get: return get_initiative()
	set(new): push_warning("Initiative é um atributo produto, portanto não pode ser definida")
var _resistance:int
var resistance:int:
	get: return get_resistance()
	set(new): push_warning("Resistance é um atributo produto, portanto não pode ser definida")
var _dodge:int
var dodge:int:
	get: return get_dodge()
	set(new): push_warning("Dodge é um atributo produto, portanto não pode ser definida")
	
var _attr_mod:Dictionary[String, int] = {}
var _attr_temp:Dictionary[String, int] = {}
	
var armor:Item=null
var weapon:Item=null
var accesory1:Item=null
var accesory2:Item=null

func _ready() -> void:
	for x in ATTRIBUTES:
		self._attr_mod[x]=0
		self._attr_temp[x]=0
	self.set_all_derivative()
	self.hp_current = hp_max
	self.mp_current = mp_max

func test_initiative() -> int:
	return generic_roll("DEX")
func attack() -> int:
	return Dice.d10()+accuracy
func give_damage() -> int:
	if weapon:
		pass
	return max(Dice.d4() + atribute_mod("STR"), 1)
func dodging() -> int:
	return self.dodge
func defend():
	var boon:int=max(atribute_mod("CON") + self.level, 1)
	set_attr_temp("RESISTANCE", boon)
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
func generic_roll(attr:String, prof_mod:bool=false, attr_modb:bool=true, temp_modb:bool=true) -> int:
	var modifier:int = atribute_mod(attr, temp_modb, attr_modb)
	if prof_mod:
		modifier+=level
	return Dice.d10() + modifier
	
# resets

func set_all_derivative()->void:
	set_hp_max()
	set_mp_max()
	set_accuracy()
	set_resistance()
	set_initiative()
	set_dodge()
	change_derivative.emit(self)
func _clear_temp():
	for x in ATTRIBUTES:
		_attr_temp[x]=0

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
		resul+=get_attr_temp("STR")
	if mod:
		resul+=get_attr_mod("STR")
	return resul
func set_STR(new):
	_STR = max(1, min(30, new))
func get_DEX(temp:bool=true, mod:bool=true)->int:
	var resul:int=_DEX
	if temp:
		resul+=get_attr_temp("DEX")
	if mod:
		resul+=get_attr_mod("DEX")
	return resul
func set_DEX(new)->void:
	_DEX = max(1, min(30, new))
	set_accuracy()
func get_CON(temp:bool=true, mod:bool=true)->int:
	var resul:int=_CON
	if temp:
		resul+=get_attr_temp("CON")
	if mod:
		resul+=get_attr_mod("CON")
	return resul
func set_CON(new)->void:
	_CON = max(1, min(30, new))
	self.set_hp_max()
func get_ESP(temp:bool=true, mod:bool=true)->int:
	var resul:int=_ESP
	if temp:
		resul+=get_attr_temp("ESP")
	if mod:
		resul+=get_attr_mod("ESP")
	return resul
func set_ESP(new)->void:
	_ESP = max(1, min(30, new))
	self.set_mp_max()
func get_hp_max(temp:bool=true, mod:bool=true)->int:
	var resul:int=_hp_max
	if temp:
		resul+=_attr_temp["HP"]
	if mod:
		resul+=_attr_mod["HP"]
	return max(resul, 1)
func set_hp_max() -> void:
	var old:int = get_hp_max()
	var new:int = self.get_CON()+floori(self.level*self.get_CON()/2.0)
	if new<_hp_current:
		self._hp_current=new
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
		resul+=_attr_temp["MP"]
	if mod:
		resul+=_attr_mod["MP"]
	return max(resul, 1)
func set_mp_max() -> void:
	var old:int = get_mp_max()
	var new:int = floori(self.get_ESP()/2.0) + floori(self.level*self.get_ESP()/4.0)
	if new<_mp_current:
		self._mp_current=new
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
		resul+=get_attr_temp("ACCURACY")
	if mod:
		resul+=get_attr_mod("ACCURACY")
	return resul
func set_accuracy()->void:
	_accuracy=atribute_mod("DEX")+get_level()
func get_initiative(temp:bool=true, mod:bool=true)->int:
	var resul:int=_initiative
	if temp:
		resul+=get_attr_temp("INITIATIVE")
	if mod:
		resul+=get_attr_mod("INITIATIVE")
	return resul
func set_initiative()->void:
	_initiative=atribute_mod("DEX")
func get_resistance(temp:bool=true, mod:bool=true)->int:
	var resul:int=_resistance
	if temp:
		resul+=get_attr_temp("RESISTANCE")
	if mod:
		resul+=get_attr_mod("RESISTANCE")
	return resul
func set_resistance()->void:
	_resistance=max(atribute_mod("CON"), 0)
func get_attr_mod(attr:String)->int:
	if _attr_mod.has(attr):
		return _attr_mod[attr]
	push_warning("Não existe esse atributo")
	return -1
func get_attr_temp(attr:String)->int:
	if _attr_temp.has(attr):
		return _attr_temp[attr]
	push_warning("Não existe esse atributo")
	return -1
func set_attr_mod(attr:String, value:int)->void:
	if _attr_mod.has(attr):
		var old:int=_attr_mod[attr]
		_attr_mod[attr]+=value
		set_all_derivative()
		var new:int=_attr_mod[attr]
		change_mod.emit(self, attr, new, old)
		return
	push_warning("Não existe esse atributo")
func set_attr_temp(attr:String, value:int)->void:
	if _attr_temp.has(attr):
		var old:int=_attr_temp[attr]
		_attr_temp[attr]+=value
		set_all_derivative()
		var new:int=_attr_temp[attr]
		change_temp.emit(self, attr, new, old)
		return
	push_warning("Não existe esse atributo")
func get_dodge(temp:bool=true, mod:bool=true)->int:
	var resul:int=_dodge
	if temp:
		resul+=get_attr_temp("DODGE")
	if mod:
		resul+=get_attr_mod("DODGE")
	return resul
func set_dodge()->void:
	self._dodge=atribute_mod("DEX")
func set_role(role_:Enum.ROLE=Enum.ROLE.ALLY):
	match role_:
		Enum.ROLE.PLAYER:
			_playable=true
			_hostile=false
			_friendly=false
		Enum.ROLE.COMPANION:
			_playable=true
			_hostile=false
			_friendly=true
		Enum.ROLE.ENEMY:
			_playable=false
			_hostile=true
			_friendly=false
		Enum.ROLE.ALLY:
			_playable=false
			_hostile=false
			_friendly=true
		Enum.ROLE.NEUTRO:
			_playable=false
			_hostile=false
			_friendly=false
		_:
			push_warning("Esse papel não existe")
			return
	change_role.emit(self, role_)
	_role=role_
func get_role()->Enum.ROLE:
	return _role
func is_playable()->bool:
	return _playable
func is_friendly()->bool:
	return _friendly
func is_hostile()->bool:
	return _hostile
