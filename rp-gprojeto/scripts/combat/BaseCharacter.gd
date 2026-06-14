#BaseCharacter
extends CharacterBody2D

class_name BaseCharacter

@export var first_name:String
@export var surname:String
# F = Feminino; M = Masculino; Não Binário = NB 
@export_enum("Masculino", "Feminino", "Não Binário") var gener:String

@export_range(0, 10) var level:int = 0

# Atributos de 1 a 20 D&D vibes
@export_range(1, 20) var STR:int = 10
var STR_mod:int = 10
@export_range(1, 20) var DEX:int = 10
var DEX_mod:int = 10
@export_range(1, 20) var CON:int = 10
var CON_mod:int = 10
@export_range(1, 20) var ESP:int = 10
var ESP_mod:int = 10
var ATR_list:Dictionary = {
	"STR": func(): return self.STR, 
	"DEX": func(): return self.DEX, 
	"CON": func(): return self.CON, 
	"ESP": func(): return self.ESP
}

@export_range(0, 0, 1, "or_greater") var hp_max:int
var hp_max_mod:int
@export var hp_current:int
@export_range(0, 0, 1, "or_greater") var mp_max:int
var mp_max_mod:int
@export var mp_current:int

# Inventário

func _init(_name:String, _gener:String, _str:int, _dex:int, _con:int, _esp:int, _level:int) -> void:
	var atrs:Array = [_str, _dex, _con, _esp]
	var regex = RegEx.new()
	_name.strip_edges().capitalize()
	regex.compile("\\s+")
	_name = regex.sub(_name, " ", true)
	for x in range(atrs.size()):
		if atrs[x]<1:
			print("[color=yellow]Aviso! O valor mínimo de um atributo é 1[/color]")
			atrs[x] = 1
	if _level > 10:
		print("[color=yellow]Aviso! O level máximo é 10[/color]")
		_level = 10
	elif _level < 1:
		print("[color=yellow]Aviso! O level mínimo é 1[/color]")
		_level = 1
	self.level = _level
	self.STR = atrs[0]
	self.DEX = atrs[1]
	self.CON = atrs[2]
	self.ESP = atrs[3]
	self.first_name = _name.split()[0]
	self.surname = "".join(_name.split().slice(1))
	self.gener = regex.sub(_gener.strip_edges().to_upper(), " ", true)
	self.hp_max = self.get_CON() + floori(self.level*self.get_CON()/2.0)
	self.hp_current = self.hp_max
	self.mp_max = floori(self.get_ESP()/2.0) + floori(self.level*self.get_ESP()/4.0)
	self.mp_current = self.mp_max
func attack(ATR_base:String="STR") -> int:
	return randi_range(1, 10) + atribute_mod(ATR_base)
func defend():
	pass
func run():
	pass
func atribute_mod(ATR:String, mod:bool=true) -> int:
	ATR.strip_edges().to_upper()
	if ATR not in self.ATR_list:
		print("[color=yellow]Error! {ATR} não é um atributo padrão na ficha! retornando 0[/color]")
		return 0
	var ATR_value:int
	if ATR == "STR":
		ATR_value = self.get_STR(mod)
	elif ATR == "DEX":
		ATR_value = self.get_DEX(mod)
	elif ATR == "CON":
		ATR_value = self.get_CON(mod)
	elif ATR == "DEX":
		ATR_value = self.get_CON(mod)
	return floori(ATR_value/2.0)-5
func get_STR(mod:bool=true) -> int:
	return self.STR+self.STR_mod if mod else self.STR
func get_DEX(mod:bool=true) -> int:
	return self.DEX+self.DEX_mod if mod else self.DEX
func get_CON(mod:bool=true) -> int:
	return self.CON+self.CON_mod if mod else self.CON
func get_ESP(mod:bool=true) -> int:
	return self.ESP+self.ESP_mod if mod else self.ESP
func get_pronoun(plural:bool=false) -> String:
	if self.gener.split()[0] in ["M", "MASCULINO", "HOMEM", "MENINO"]:
		return "e" if not plural else "es"
	if self.gener in ["F", "FEMININO", "MULHER", "MENINA"]:
		return "a" if not plural else "as"
	else:
		return "u" if not plural else "us"
