# Um "bloquinho" (tile) do inventário. Construído por código (sem precisar de cena).
# Mostra nome + quantidade, cor por tipo, tooltip com informações e suporta
# clique (usar/largar) e arrastar (reorganizar).

class_name InventorySlot
extends PanelContainer

signal slot_clicked(index: int, button: int)
signal request_move(from_index: int, to_index: int)

const TILE_SIZE := Vector2(76, 76)

var index: int = -1
var slot_data: Dictionary = {}     # {"item": Item, "count": int} ou {} se vazio

var _label: Label
var _count: Label
var _style: StyleBoxFlat

func _ready() -> void:
	custom_minimum_size = TILE_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP

	_style = StyleBoxFlat.new()
	_style.set_corner_radius_all(6)
	_style.set_border_width_all(2)
	_style.border_color = Color(0.30, 0.30, 0.38)
	_style.set_content_margin_all(4)
	add_theme_stylebox_override("panel", _style)

	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", 11)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_label)

	_count = Label.new()
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_count.add_theme_font_size_override("font_size", 11)
	_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_count)

	_update_view()

func set_data(i: int, data: Dictionary) -> void:
	index = i
	slot_data = data
	if _label != null:
		_update_view()

func _update_view() -> void:
	if slot_data.is_empty():
		_label.text = ""
		_count.text = ""
		tooltip_text = ""
		_style.bg_color = Color(0.13, 0.13, 0.16)
		return
	var it = slot_data["item"]
	var c: int = slot_data["count"]
	_label.text = it.name
	_count.text = ("x%d" % c) if c > 1 else ""
	tooltip_text = _tooltip_for(it)
	_style.bg_color = _color_for(it.type)

# Tooltip com as informações do item, incluindo os campos 
# de combate quando existirem
func _tooltip_for(it: Item) -> String:
	var t := "%s\n[%s]  •  Valor: %d" % [it.name, it.type_label(), it.value]
	if it.dano_base > 0 or it.penetracao > 0:
		t += "\nDano: %d  •  Penetração: %d" % [it.dano_base, it.penetracao]
	if it.armadura > 0:
		t += "\nArmadura: %d" % it.armadura
	for stat in it.stat_bonus:
		t += "\n%s: %+d" % [str(stat).to_upper(), int(it.stat_bonus[stat])]
	if it.type == Item.Type.SPECIAL:
		t += "\n(clique para usar)"
	t += "\n" + it.description
	return t

func _color_for(t: int) -> Color:
	match t:
		Item.Type.CONSUMABLE:
			return Color(0.18, 0.32, 0.22)
		Item.Type.EQUIPABLE:
			return Color(0.20, 0.26, 0.40)
		Item.Type.QUEST:
			return Color(0.36, 0.28, 0.16)
		Item.Type.SPECIAL:
			return Color(0.32, 0.20, 0.38)
	return Color(0.16, 0.16, 0.20)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			slot_clicked.emit(index, MOUSE_BUTTON_LEFT)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			slot_clicked.emit(index, MOUSE_BUTTON_RIGHT)

# ----- Drag & drop: reorganizar em qualquer ordem -----
func _get_drag_data(_at: Vector2):
	if slot_data.is_empty():
		return null
	var preview := PanelContainer.new()
	preview.custom_minimum_size = TILE_SIZE
	var pl := Label.new()
	pl.text = slot_data["item"].name
	pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview.add_child(pl)
	preview.modulate.a = 0.75
	set_drag_preview(preview)
	return {"type": "inv_slot", "from": index}

func _can_drop_data(_at: Vector2, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.get("type", "") == "inv_slot"

func _drop_data(_at: Vector2, data) -> void:
	request_move.emit(int(data["from"]), index)
