# Tela do inventário (construída por código). Abre/fecha por tecla de atalho,
# mostra a grade em tiles, botões de organização (Quicksort), e o painel do
# personagem (moedas, status e itens equipados).

class_name InventoryUI
extends CanvasLayer

@export var toggle_key: int = KEY_I     # tecla de atalho para abrir/fechar
@export var columns: int = 6

var inventory: Inventory

var _root: Control
var _grid: GridContainer
var _coins_label: Label
var _stats_label: Label
var _equip_box: VBoxContainer
var _slots: Array[InventorySlot] = []

func _ready() -> void:
	_build()
	if inventory != null:
		_bind(inventory)
	_root.visible = false

func set_inventory(inv: Inventory) -> void:
	inventory = inv
	if _root != null:
		_bind(inv)

func _bind(inv: Inventory) -> void:
	if not inv.changed.is_connected(_refresh):
		inv.changed.connect(_refresh)
	if not inv.equipment_changed.is_connected(_refresh):
		inv.equipment_changed.connect(_refresh)
	_refresh()

# ---------------- construção da interface ----------------
func _build() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)

	var window := PanelContainer.new()
	center.add_child(window)

	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 16)
	window.add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	margin.add_child(col)

	var title := Label.new()
	title.text = "Inventário"
	title.add_theme_font_size_override("font_size", 22)
	col.add_child(title)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	col.add_child(body)

	# --- coluna esquerda: organização + grade ---
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 8)
	body.add_child(left)

	var sort_row := HBoxContainer.new()
	sort_row.add_theme_constant_override("separation", 6)
	left.add_child(sort_row)

	var sort_label := Label.new()
	sort_label.text = "Organizar:"
	sort_row.add_child(sort_label)
	sort_row.add_child(_make_sort_button("Nome A-Z", InventorySort.Criteria.NAME))
	sort_row.add_child(_make_sort_button("Tipo", InventorySort.Criteria.TYPE))
	sort_row.add_child(_make_sort_button("Valor ↑", InventorySort.Criteria.VALUE_ASC))
	sort_row.add_child(_make_sort_button("Valor ↓", InventorySort.Criteria.VALUE_DESC))

	_grid = GridContainer.new()
	_grid.columns = columns
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	left.add_child(_grid)

	var hint := Label.new()
	hint.text = "Clique esq.: usar / equipar   •   Clique dir.: largar   •   Arraste: reorganizar"
	hint.add_theme_font_size_override("font_size", 11)
	hint.modulate = Color(0.8, 0.8, 0.8)
	left.add_child(hint)

	body.add_child(VSeparator.new())

	# --- coluna direita: painel do personagem ---
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(220, 0)
	right.add_theme_constant_override("separation", 8)
	body.add_child(right)

	var p_title := Label.new()
	p_title.text = "Personagem"
	p_title.add_theme_font_size_override("font_size", 16)
	right.add_child(p_title)

	_coins_label = Label.new()
	right.add_child(_coins_label)

	_stats_label = Label.new()
	_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_stats_label)

	var eq_title := Label.new()
	eq_title.text = "Equipado"
	eq_title.add_theme_font_size_override("font_size", 14)
	right.add_child(eq_title)

	_equip_box = VBoxContainer.new()
	_equip_box.add_theme_constant_override("separation", 4)
	right.add_child(_equip_box)

	# --- cria os tiles da grade uma única vez ---
	for i in range(Inventory.MAX_SLOTS):
		var slot := InventorySlot.new()
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.request_move.connect(_on_request_move)
		_grid.add_child(slot)
		_slots.append(slot)

func _make_sort_button(text: String, criteria: int) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(func(): _on_sort(criteria))
	return b

# ---------------- atualização ----------------
func _refresh() -> void:
	if inventory == null:
		return
	for i in range(_slots.size()):
		if i < inventory.slots.size():
			_slots[i].set_data(i, inventory.slots[i])
		else:
			_slots[i].set_data(i, {})
	_coins_label.text = "Moedas: %d" % inventory.coins
	var st := inventory.get_total_stats()
	_stats_label.text = "HP: %d/%d\nATK: %d\nDEF: %d\nPEN: %d" % [
		int(st.get("hp", 0)), int(st.get("max_hp", 0)),
		int(st.get("atk", 0)), int(st.get("def", 0)),
		int(st.get("pen", 0))
	]
	_refresh_equipped()

func _refresh_equipped() -> void:
	for c in _equip_box.get_children():
		c.queue_free()
	var any := false
	for slot_key in inventory.equipped:
		var it = inventory.equipped[slot_key]
		if it == null:
			continue
		any = true
		var b := Button.new()
		b.text = "%s: %s  (tirar)" % [_equip_slot_name(slot_key), it.name]
		b.pressed.connect(func(): inventory.unequip(slot_key))
		_equip_box.add_child(b)
	if not any:
		var l := Label.new()
		l.text = "(nada equipado)"
		l.modulate = Color(0.7, 0.7, 0.7)
		_equip_box.add_child(l)

func _equip_slot_name(k: int) -> String:
	match k:
		Item.EquipSlot.WEAPON:
			return "Arma"
		Item.EquipSlot.ARMOR:
			return "Armadura"
		Item.EquipSlot.ACCESSORY:
			return "Acessório"
	return "Slot"

# ---------------- interação ----------------
func _on_slot_clicked(index: int, button: int) -> void:
	if inventory == null or index >= inventory.slots.size():
		return
	var item: Item = inventory.slots[index]["item"]
	if button == MOUSE_BUTTON_LEFT:
		if item.type == Item.Type.CONSUMABLE:
			inventory.consume(index)
		elif item.type == Item.Type.EQUIPABLE:
			inventory.equip(index)
		elif item.type == Item.Type.SPECIAL:
			var abre_dialogo: bool = item.efeito_especial == "dialogo"
			if inventory.usar_especial(index) and abre_dialogo:
				close()   # fecha o inventário pra caixa de diálogo aparecer livre
	elif button == MOUSE_BUTTON_RIGHT:
		inventory.drop(index, 1)

func _on_request_move(from_index: int, to_index: int) -> void:
	if inventory == null or from_index >= inventory.slots.size():
		return
	var target: int = to_index
	if target >= inventory.slots.size():
		target = inventory.slots.size() - 1
	inventory.move_slot(from_index, target)

func _on_sort(criteria: int) -> void:
	if inventory == null:
		return
	# Mede o tempo da ordenação — evidência do RNF "< 1s no pior caso".
	var t0 := Time.get_ticks_usec()
	inventory.sort_by(criteria)
	var dt_ms := (Time.get_ticks_usec() - t0) / 1000.0
	print("Ordenação de %d itens em %.3f ms" % [inventory.slots.size(), dt_ms])

# ---------------- tecla de atalho ----------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == toggle_key:
		toggle()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	_root.visible = not _root.visible
	if _root.visible:
		_refresh()

func open() -> void:
	_root.visible = true
	_refresh()

func close() -> void:
	_root.visible = false
