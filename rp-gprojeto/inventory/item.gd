# Item.gd
# Definição de um item do jogo como Resource customizado.
# Usar Resource permite (depois) criar itens como assets .tres no editor do Godot.

class_name Item
extends Resource

enum Type { CONSUMABLE, EQUIPABLE, QUEST }       # consumível, equipável, missão
enum EquipSlot { NONE, WEAPON, ARMOR, ACCESSORY }

@export var id: String = ""
@export var name: String = ""
@export_multiline var description: String = ""
@export var type: Type = Type.CONSUMABLE
@export var value: int = 0                        # usado na ordenação por valor e na economia
@export var icon: Texture2D                       # opcional; a UI mostra o nome se não houver arte
@export var stackable: bool = true
@export var equip_slot: EquipSlot = EquipSlot.NONE
@export var heal_amount: int = 0                  # efeito de consumível
@export var stat_bonus: Dictionary = {}           # ex.: {"atk": 5, "def": 2, "max_hp": 10}

func type_label() -> String:
	match type:
		Type.CONSUMABLE:
			return "Consumível"
		Type.EQUIPABLE:
			return "Equipável"
		Type.QUEST:
			return "Missão"
	return "?"
