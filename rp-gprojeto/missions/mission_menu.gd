# MissionMenu.gd
# Tela de missões (construída por código, igual à do inventário). Abre por
# tecla de atalho e mostra: lista de missões, nome, descrição, objetivo atual
# e os botões de escolha quando há ramificação.

class_name MissionMenu
extends CanvasLayer

@export var toggle_key: int = KEY_J     # tecla pra abrir/fechar o menu de missões

signal aberto_mudou(aberto)             # avisa o HUD quando o menu abre/fecha

var manager: MissionManager

var _root: Control
var _lista: VBoxContainer
var _titulo: Label
var _descricao: Label
var _objetivo: Label
var _escolhas_box: VBoxContainer
var _selecionado: String = ""

func _ready() -> void:
	_build()
	if manager != null:
		_bind(manager)
	_root.visible = false

func set_manager(m: MissionManager) -> void:
	manager = m
	if _root != null:
		_bind(m)

func _bind(m: MissionManager) -> void:
	for sig in [m.missao_iniciada, m.missao_atualizada, m.missao_concluida]:
		if not sig.is_connected(_on_mudou):
			sig.connect(_on_mudou)
	_refresh()

func _on_mudou(_id: String) -> void:
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
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(lado, 16)
	window.add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	col.custom_minimum_size = Vector2(560, 0)
	margin.add_child(col)

	var titulo_tela := Label.new()
	titulo_tela.text = "Missões"
	titulo_tela.add_theme_font_size_override("font_size", 22)
	col.add_child(titulo_tela)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	col.add_child(body)

	# esquerda: lista de missões
	var esq := VBoxContainer.new()
	esq.custom_minimum_size = Vector2(190, 0)
	esq.add_theme_constant_override("separation", 6)
	body.add_child(esq)
	var lbl_lista := Label.new()
	lbl_lista.text = "Suas missões"
	lbl_lista.add_theme_font_size_override("font_size", 14)
	esq.add_child(lbl_lista)
	_lista = VBoxContainer.new()
	_lista.add_theme_constant_override("separation", 4)
	esq.add_child(_lista)

	body.add_child(VSeparator.new())

	# direita: detalhes da missão selecionada
	var dir := VBoxContainer.new()
	dir.custom_minimum_size = Vector2(320, 0)
	dir.add_theme_constant_override("separation", 8)
	body.add_child(dir)

	_titulo = Label.new()
	_titulo.add_theme_font_size_override("font_size", 18)
	dir.add_child(_titulo)

	_descricao = Label.new()
	_descricao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dir.add_child(_descricao)

	_objetivo = Label.new()
	_objetivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objetivo.add_theme_color_override("font_color", Color(0.92, 0.85, 0.5))
	dir.add_child(_objetivo)

	var lbl_esc := Label.new()
	lbl_esc.text = "Ações:"
	lbl_esc.add_theme_font_size_override("font_size", 13)
	dir.add_child(lbl_esc)

	_escolhas_box = VBoxContainer.new()
	_escolhas_box.add_theme_constant_override("separation", 4)
	dir.add_child(_escolhas_box)

	var hint := Label.new()
	hint.text = "J para fechar"
	hint.add_theme_font_size_override("font_size", 11)
	hint.modulate = Color(0.8, 0.8, 0.8)
	col.add_child(hint)

# ---------------- atualização ----------------
func _refresh() -> void:
	if manager == null:
		return
	for c in _lista.get_children():
		c.queue_free()
	var missoes: Array = manager.lista()
	# seleção padrão
	if not manager.missoes.has(_selecionado):
		if manager.missoes.has(manager.foco):
			_selecionado = manager.foco
		elif not missoes.is_empty():
			_selecionado = missoes[0].id
		else:
			_selecionado = ""
	if missoes.is_empty():
		var l := Label.new()
		l.text = "(nenhuma missão)"
		l.modulate = Color(0.7, 0.7, 0.7)
		_lista.add_child(l)
	for m in missoes:
		var b := Button.new()
		b.text = ("✓ " if m.concluida else "• ") + m.titulo
		var mid: String = m.id
		b.pressed.connect(func(): _selecionar(mid))
		_lista.add_child(b)
	_atualizar_detalhes()

func _selecionar(id: String) -> void:
	_selecionado = id
	_atualizar_detalhes()

func _atualizar_detalhes() -> void:
	for c in _escolhas_box.get_children():
		c.queue_free()
	if manager == null or not manager.missoes.has(_selecionado):
		_titulo.text = ""
		_descricao.text = ""
		_objetivo.text = ""
		return
	var m: Mission = manager.missoes[_selecionado]
	_titulo.text = m.titulo
	_descricao.text = m.descricao()
	_objetivo.text = "Objetivo: " + m.objetivo()
	if m.concluida:
		var l := Label.new()
		l.text = "✓ Missão concluída"
		l.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
		_escolhas_box.add_child(l)
		return
	# missão automática: avança sozinha pelo mundo, sem botões pra clicar
	if m.auto:
		var l := Label.new()
		l.text = "↳ Em andamento — siga o objetivo no mapa."
		l.modulate = Color(0.7, 0.8, 0.95)
		_escolhas_box.add_child(l)
		return
	var ops: Array = m.escolhas()
	if ops.is_empty():
		var l := Label.new()
		l.text = "(sem ações no momento)"
		l.modulate = Color(0.7, 0.7, 0.7)
		_escolhas_box.add_child(l)
	else:
		for i in range(ops.size()):
			var b := Button.new()
			b.text = ops[i].get("texto", "Continuar")
			var idx: int = i
			var mid: String = m.id
			b.pressed.connect(func(): manager.escolher(mid, idx))
			_escolhas_box.add_child(b)

# ---------------- tecla de atalho ----------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == toggle_key:
		toggle()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	_root.visible = not _root.visible
	if _root.visible:
		_refresh()
	aberto_mudou.emit(_root.visible)
