extends BaseCharacter

class_name Player

func _ready() -> void:
	self.hp_max = self.get_CON()+floori(self.level*self.get_CON()/2.0)
	self.mp_max = floori(self.get_ESP()/2.0) + floori(self.level*self.get_ESP()/4.0)
	self.hp_current = hp_max
	self.mp_current = mp_max
