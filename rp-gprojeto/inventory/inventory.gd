# Estrutura de dados do inventário + todas as operações da US-02.
# Mantém: bolsa (slots), moedas, itens equipados e status base do personagem.

class_name Inventory
extends RefCounted

signal changed                          # a bolsa mudou (redesenhar grade)
signal equipment_changed                # equipamento mudou
signal coins_changed(amount: int)
signal item_dropped(item: Item, count: int)   # o mundo escuta para spawnar no chão

const MAX_SLOTS: int = 24

var slots: Array = []                    # cada elemento: {"item": Item, "count": int}
var coins: int = 0
var equipped: Dictionary = {}            # Item.EquipSlot -> Item
var base_stats: Dictionary = {"hp": 30, "max_hp": 30, "atk": 5, "def": 3}

# ---------------- coleta / armazenamento ----------------
func add_item(item: Item, count: int = 1) -> bool:
	if item == null or count <= 0:
		return false
	var remaining: int = count
	if item.stackable:
		var idx: int = _find_slot(item)
		if idx != -1:
			slots[idx]["count"] += remaining
			remaining = 0
	while remaining > 0:
		if slots.size() >= MAX_SLOTS:
			changed.emit()
			return false   # inventário cheio: não coube tudo
		if item.stackable:
			slots.append({"item": item, "count": remaining})
			remaining = 0
		else:
			slots.append({"item": item, "count": 1})
			remaining -= 1
	changed.emit()
	return true

func remove_item(item: Item, count: int = 1) -> bool:
	var idx: int = _find_slot(item)
	if idx == -1:
		return false
	var ok := _remove_at(idx, count)
	changed.emit()
	return ok

func has_item(item: Item) -> bool:
	return _find_slot(item) != -1

func get_count(item: Item) -> int:
	var idx: int = _find_slot(item)
	return slots[idx]["count"] if idx != -1 else 0

# ---------------- ações no inventário ----------------
func consume(index: int) -> bool:
	if not _valid(index):
		return false
	var item: Item = slots[index]["item"]
	if item.type != Item.Type.CONSUMABLE:
		return false
	if item.heal_amount > 0:
		base_stats["hp"] = mini(base_stats["hp"] + item.heal_amount, base_stats["max_hp"])
	_remove_at(index, 1)
	changed.emit()
	return true

# Usa um item ESPECIAL: efeitos diversos conforme item.efeito_especial.
#   "dialogo"  -> abre caixa de diálogo com as linhas do item
#   "atributo" -> modifica atributos da ficha (ex.: elixir que dá +5 max_hp)
func usar_especial(index: int) -> bool:
	if not _valid(index):
		return false
	var item: Item = slots[index]["item"]
	if item.type != Item.Type.SPECIAL:
		return false
	var dados: Dictionary = item.efeito_dados
	match item.efeito_especial:
		"dialogo":
			DialogueUI.start_dialogue(Array(dados.get("linhas", ["..."]), TYPE_STRING, "", null))
		"atributo":
			for stat in dados.get("stats", {}):
				base_stats[stat] = int(base_stats.get(stat, 0)) + int(dados["stats"][stat])
			if base_stats.has("hp") and base_stats.has("max_hp"):
				base_stats["hp"] = mini(base_stats["hp"], base_stats["max_hp"])
		_:
			return false
	if dados.get("consumir", false):
		_remove_at(index, 1)
	changed.emit()
	return true

func equip(index: int) -> bool:
	if not _valid(index):
		return false
	var item: Item = slots[index]["item"]
	if item.type != Item.Type.EQUIPABLE:
		return false
	_remove_at(index, 1)
	var key: int = item.equip_slot
	if equipped.has(key) and equipped[key] != null:
		add_item(equipped[key], 1)   # devolve o que estava equipado para a bolsa
	equipped[key] = item
	equipment_changed.emit()
	changed.emit()
	return true

func unequip(equip_slot: int) -> bool:
	if not equipped.has(equip_slot) or equipped[equip_slot] == null:
		return false
	var item: Item = equipped[equip_slot]
	equipped[equip_slot] = null
	add_item(item, 1)
	equipment_changed.emit()
	changed.emit()
	return true

func drop(index: int, count: int = 1) -> bool:
	if not _valid(index):
		return false
	var item: Item = slots[index]["item"]
	var n: int = mini(count, slots[index]["count"])
	_remove_at(index, n)
	item_dropped.emit(item, n)   # o mundo (mapa) cria o item no chão
	changed.emit()
	return true

# Reordenação manual (drag & drop): "organizar em qualquer ordem".
func move_slot(from_index: int, to_index: int) -> void:
	if from_index == to_index:
		return
	if not _valid(from_index) or to_index < 0 or to_index >= slots.size():
		return
	var s = slots[from_index]
	slots.remove_at(from_index)
	slots.insert(to_index, s)
	changed.emit()

# Organização automática (Quicksort).
func sort_by(criteria: int) -> void:
	InventorySort.sort_slots(slots, criteria)
	changed.emit()

# ---------------- economia / status ----------------
func set_coins(amount: int) -> void:
	coins = maxi(0, amount)
	coins_changed.emit(coins)
	changed.emit()

func add_coins(amount: int) -> void:
	set_coins(coins + amount)

# Status totais calculados NA HORA (base + equipados). Os efeitos dos itens
# equipados nunca alteram a ficha base  — tirar o item, tira o efeito.
func get_total_stats() -> Dictionary:
	var total: Dictionary = base_stats.duplicate()
	total["pen"] = int(total.get("pen", 0))
	for key in equipped:
		var it = equipped[key]
		if it == null:
			continue
		for stat in it.stat_bonus:
			total[stat] = int(total.get(stat, 0)) + int(it.stat_bonus[stat])
		# campos de combate 
		total["atk"] = int(total.get("atk", 0)) + it.dano_base
		total["pen"] = int(total.get("pen", 0)) + it.penetracao
		total["def"] = int(total.get("def", 0)) + it.armadura
	if total.has("hp") and total.has("max_hp"):
		total["hp"] = mini(int(total["hp"]), int(total["max_hp"]))
	return total

# ---------------- salvar / carregar (JSON) ----------------
func to_dict() -> Dictionary:
	var bag: Array = []
	for s in slots:
		bag.append({"id": s["item"].id, "count": s["count"]})
	var eq: Dictionary = {}
	for k in equipped:
		if equipped[k] != null:
			eq[str(k)] = equipped[k].id
	return {"coins": coins, "base_stats": base_stats, "bag": bag, "equipped": eq}

func from_dict(data: Dictionary) -> void:
	slots.clear()
	equipped.clear()
	coins = int(data.get("coins", 0))
	base_stats = data.get("base_stats", base_stats).duplicate()
	for entry in data.get("bag", []):
		var it = ItemDatabase.get_item(entry.get("id", ""))
		if it != null:
			slots.append({"item": it, "count": int(entry.get("count", 1))})
	for k in data.get("equipped", {}):
		var it2 = ItemDatabase.get_item(data["equipped"][k])
		if it2 != null:
			equipped[int(k)] = it2
	equipment_changed.emit()
	changed.emit()

# ---------------- helpers ----------------
func _find_slot(item: Item) -> int:
	for i in range(slots.size()):
		if slots[i]["item"].id == item.id:
			return i
	return -1

func _remove_at(index: int, count: int) -> bool:
	if not _valid(index):
		return false
	slots[index]["count"] -= count
	if slots[index]["count"] <= 0:
		slots.remove_at(index)
	return true

func _valid(index: int) -> bool:
	return index >= 0 and index < slots.size()
