# ItemDatabase.gd
# Catálogo de itens de exemplo (criados em código) para o protótipo rodar
# imediatamente, sem precisar montar assets .tres. Também resolve ids ao carregar save.

class_name ItemDatabase
extends RefCounted

static var _items: Dictionary = {}
static var _built: bool = false

static func _ensure() -> void:
	if _built:
		return
	_built = true
	_register(_make("potion_s", "Poção Pequena", Item.Type.CONSUMABLE, 10, {
		"desc": "Restaura 15 de HP.", "heal": 15
	}))
	_register(_make("potion_l", "Poção Grande", Item.Type.CONSUMABLE, 30, {
		"desc": "Restaura 40 de HP.", "heal": 40
	}))
	# Equipáveis de dano: dano base + penetração 
	_register(_make("sword_rusty", "Espada Enferrujada", Item.Type.EQUIPABLE, 25, {
		"desc": "Uma lâmina velha, mas ainda corta.",
		"stackable": false, "slot": Item.EquipSlot.WEAPON, "dano": 4, "pen": 1
	}))
	# Equipáveis de proteção: pontos de armadura 
	_register(_make("armor_leather", "Armadura de Couro", Item.Type.EQUIPABLE, 40, {
		"desc": "Proteção leve contra a gosma.",
		"stackable": false, "slot": Item.EquipSlot.ARMOR, "armadura": 5, "bonus": {"max_hp": 10}
	}))
	_register(_make("ring_ink", "Anel de Tinta", Item.Type.EQUIPABLE, 80, {
		"desc": "Pulsa com a essência de Ink.",
		"stackable": false, "slot": Item.EquipSlot.ACCESSORY, "bonus": {"atk": 2, "def": 2}
	}))
	_register(_make("key_ancient", "Chave Antiga", Item.Type.QUEST, 0, {
		"desc": "Abre algo esquecido.", "stackable": false
	}))
	_register(_make("map_fragment", "Fragmento de Mapa", Item.Type.QUEST, 0, {
		"desc": "Parte de um mapa rasgado."
	}))
	# Especiais: efeitos diversos 
	_register(_make("pergaminho_velho", "Pergaminho Velho", Item.Type.SPECIAL, 15, {
		"desc": "Letras de tinta se mexem sozinhas no papel.",
		"stackable": false, "efeito": "dialogo", "efeito_dados": {
			"linhas": [
				"O pergaminho sussurra: 'A tinta lembra o que o mundo esqueceu...'",
				"'Procure a fenda onde a luz atravessa. Lá começa a jornada.'"
			],
			"consumir": false
		}
	}))
	_register(_make("elixir_vigor", "Elixir do Vigor", Item.Type.SPECIAL, 60, {
		"desc": "Aumenta permanentemente o vigor (+5 HP máximo).",
		"efeito": "atributo", "efeito_dados": {
			"stats": {"max_hp": 5},
			"consumir": true
		}
	}))

static func _make(id: String, nm: String, type: int, value: int, opts: Dictionary = {}) -> Item:
	var it := Item.new()
	it.id = id
	it.name = nm
	it.type = type
	it.value = value
	it.description = opts.get("desc", "")
	it.stackable = opts.get("stackable", type == Item.Type.CONSUMABLE)
	it.heal_amount = opts.get("heal", 0)
	it.equip_slot = opts.get("slot", Item.EquipSlot.NONE)
	it.stat_bonus = opts.get("bonus", {})
	it.dano_base = opts.get("dano", 0)
	it.penetracao = opts.get("pen", 0)
	it.armadura = opts.get("armadura", 0)
	it.efeito_especial = opts.get("efeito", "")
	it.efeito_dados = opts.get("efeito_dados", {})
	return it

static func _register(it: Item) -> void:
	_items[it.id] = it

static func get_item(id: String) -> Item:
	_ensure()
	return _items.get(id, null)

static func all_items() -> Array:
	_ensure()
	return _items.values()
