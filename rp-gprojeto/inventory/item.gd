# Item.gd
# Definição de um item do jogo como Resource customizado.
# Usar Resource permite (depois) criar itens como assets .tres no editor do Godot.

class_name Item
extends Resource

enum Type { CONSUMABLE, EQUIPABLE, QUEST, SPECIAL }   # consumível, equipável, missão, especial
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

# Combate — itens que causam dano e itens que protegem.
# Entram no cálculo do get_total_stats() enquanto equipados; a "ficha" base
# do personagem nunca é alterada por equipamento.
@export var dano_base: int = 0                    # arma: dano base
@export var penetracao: int = 0                   # arma: pontos de penetração
@export var armadura: int = 0                     # proteção: pontos de armadura

# Especiais — efeitos diversos ao usar:
#   "dialogo"  -> abre caixa de diálogo; efeito_dados = {"linhas": [..], "consumir": bool}
#   "atributo" -> modifica um atributo da ficha; efeito_dados = {"stats": {"max_hp": 5}, "consumir": true}
@export var efeito_especial: String = ""
@export var efeito_dados: Dictionary = {}

func type_label() -> String:
	match type:
		Type.CONSUMABLE:
			return "Consumível"
		Type.EQUIPABLE:
			return "Equipável"
		Type.QUEST:
			return "Missão"
		Type.SPECIAL:
			return "Especial"
	return "?"
