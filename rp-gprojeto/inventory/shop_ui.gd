# ShopUI.gd
# Tela da loja (US-10), construída por código. Mostra o que dá pra comprar e o
# que dá pra vender, com preços e tooltips. O jogador monta o carrinho, vê o
# montante ao vivo e fecha o negócio no botão Confirmar.
class_name ShopUI
extends CanvasLayer

var inventory: Inventory
var shop: Shop

var _root: Control
var _buy_list: VBoxContainer
var _sell_list: VBoxContainer
var _coins_label: Label
var _montante_label: Label
var _apos_label: Label
var _aviso_label: Label
var _confirm_btn: Button

func _ready() -> void:
	_build()
	_root.visible = false

# Abre a loja com o estoque do mercador (lista de ids de item).
func abrir(estoque: Array) -> void:
	if inventory == null:
		inventory = Game.inventory
	shop = Shop.new()
	shop.inventory = inventory
	shop.estoque = estoque
	_root.visible = true
	_refresh()

func fechar() -> void:
	_root.visible = false

func aberta() -> bool:
	return _root != null and _root.visible

# ---------------- construção ----------------
func _build() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
	col.custom_minimum_size = Vector2(620, 0)
	margin.add_child(col)

	var titulo := Label.new()
	titulo.text = "Loja"
	titulo.add_theme_font_size_override("font_size", 22)
	col.add_child(titulo)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	col.add_child(body)

	# coluna comprar
	body.add_child(_coluna("Comprar", true))
	body.add_child(VSeparator.new())
	# coluna vender
	body.add_child(_coluna("Vender", false))

	col.add_child(HSeparator.new())

	# painel de balanço
	_coins_label = Label.new()
	col.add_child(_coins_label)
	_montante_label = Label.new()
	col.add_child(_montante_label)
	_apos_label = Label.new()
	_apos_label.add_theme_font_size_override("font_size", 16)
	col.add_child(_apos_label)

	# aviso do motivo de não dar pra confirmar (cheio / sem moeda)
	_aviso_label = Label.new()
	_aviso_label.add_theme_color_override("font_color", Color(0.95, 0.55, 0.5))
	_aviso_label.add_theme_font_size_override("font_size", 13)
	col.add_child(_aviso_label)

	var botoes := HBoxContainer.new()
	botoes.add_theme_constant_override("separation", 8)
	col.add_child(botoes)
	_confirm_btn = Button.new()
	_confirm_btn.text = "Confirmar"
	_confirm_btn.pressed.connect(_on_confirmar)
	botoes.add_child(_confirm_btn)
	var fechar_btn := Button.new()
	fechar_btn.text = "Fechar (Esc)"
	fechar_btn.pressed.connect(fechar)
	botoes.add_child(fechar_btn)

# cria uma coluna (comprar/vender) com título e a lista que será preenchida
func _coluna(titulo: String, eh_compra: bool) -> VBoxContainer:
	var c := VBoxContainer.new()
	c.custom_minimum_size = Vector2(290, 320)
	c.add_theme_constant_override("separation", 6)
	var lbl := Label.new()
	lbl.text = titulo
	lbl.add_theme_font_size_override("font_size", 15)
	c.add_child(lbl)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(290, 300)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	c.add_child(scroll)
	var lista := VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation", 4)
	scroll.add_child(lista)
	if eh_compra:
		_buy_list = lista
	else:
		_sell_list = lista
	return c

# ---------------- atualização ----------------
func _refresh() -> void:
	if shop == null:
		return
	for n in _buy_list.get_children():
		n.queue_free()
	for n in _sell_list.get_children():
		n.queue_free()

	# comprar: o estoque do mercador
	for id in shop.estoque:
		var item := ItemDatabase.get_item(id)
		if item == null:
			continue
		_buy_list.add_child(_linha(item, shop.preco_compra(item),
			int(shop.compras.get(id, 0)), true))

	# vender: itens do jogador que não são de missão (agregados por id)
	var vistos: Dictionary = {}
	for s in inventory.slots:
		var it: Item = s["item"]
		if it.type == Item.Type.QUEST or vistos.has(it.id):
			continue
		vistos[it.id] = true
		_sell_list.add_child(_linha(it, shop.preco_venda(it),
			int(shop.vendas.get(it.id, 0)), false))
	if _sell_list.get_child_count() == 0:
		var vazio := Label.new()
		vazio.text = "(nada pra vender)"
		vazio.modulate = Color(0.7, 0.7, 0.7)
		_sell_list.add_child(vazio)

	_atualizar_balanco()

# uma linha de item: nome + preço, contador no carrinho e botões [-] [+]
func _linha(item: Item, preco: int, qtd_carrinho: int, eh_compra: bool) -> PanelContainer:
	var painel := PanelContainer.new()
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 6)
	painel.add_child(linha)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var nome := Label.new()
	nome.text = item.name
	nome.tooltip_text = "%s\n[%s] • Valor: %d\n%s" % [item.name, item.type_label(), item.value, item.description]
	info.add_child(nome)
	var preco_lbl := Label.new()
	preco_lbl.text = ("Compra: %d" % preco) if eh_compra else ("Venda: %d" % preco)
	preco_lbl.add_theme_font_size_override("font_size", 11)
	preco_lbl.modulate = Color(0.85, 0.82, 0.5)
	info.add_child(preco_lbl)
	linha.add_child(info)

	var menos := Button.new()
	menos.text = "−"
	menos.custom_minimum_size = Vector2(30, 0)
	linha.add_child(menos)

	var qtd := Label.new()
	qtd.text = str(qtd_carrinho)
	qtd.custom_minimum_size = Vector2(22, 0)
	qtd.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	linha.add_child(qtd)

	var mais := Button.new()
	mais.text = "+"
	mais.custom_minimum_size = Vector2(30, 0)
	linha.add_child(mais)

	var id: String = item.id
	if eh_compra:
		mais.pressed.connect(func(): shop.add_compra(id); _refresh())
		menos.pressed.connect(func(): shop.tira_compra(id); _refresh())
	else:
		mais.pressed.connect(func(): shop.add_venda(id); _refresh())
		menos.pressed.connect(func(): shop.tira_venda(id); _refresh())
	return painel

func _atualizar_balanco() -> void:
	var m: int = shop.montante()
	_coins_label.text = "Moedas: %d" % inventory.coins
	_montante_label.text = "Montante: %s%d" % [("+" if m >= 0 else ""), m]
	_montante_label.modulate = Color(0.5, 0.9, 0.5) if m >= 0 else Color(0.95, 0.55, 0.5)
	_apos_label.text = "Moedas após: %d" % shop.moedas_apos()
	_confirm_btn.disabled = not shop.pode_confirmar()
	# explica por que o Confirmar está bloqueado
	if shop.compras.is_empty() and shop.vendas.is_empty():
		_aviso_label.text = ""
	elif not shop.tem_moedas():
		_aviso_label.text = "Moedas insuficientes"
	elif not shop.cabe_no_inventario():
		_aviso_label.text = "Sem espaço no inventário (venda algo antes)"
	else:
		_aviso_label.text = ""

# ---------------- ações ----------------
func _on_confirmar() -> void:
	if shop.confirmar():
		Game.notify("Negócio fechado!")
		_refresh()
	elif not shop.tem_moedas():
		Game.notify("Moedas insuficientes!")
	elif not shop.cabe_no_inventario():
		Game.notify("Inventário cheio!")

func _input(event: InputEvent) -> void:
	if _root.visible and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		fechar()
		get_viewport().set_input_as_handled()
