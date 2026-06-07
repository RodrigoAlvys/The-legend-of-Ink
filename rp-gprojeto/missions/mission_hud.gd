# MissionHUD.gd
# Rastreador de missão fixo na tela (canto superior direito). Mostra só a
# missão EM FOCO: título + objetivo atual. Atualiza sozinho pelos sinais do
# MissionManager. Some quando não há missão ativa e quando o menu J está aberto.

class_name MissionHUD
extends CanvasLayer

var manager: MissionManager
var menu: MissionMenu              # opcional: some o HUD quando o menu J abre

var _painel: PanelContainer
var _titulo: Label
var _objetivo: Label
var _menu_aberto: bool = false

func _ready() -> void:
	_build()
	if manager != null:
		_bind(manager)
	if menu != null:
		menu.aberto_mudou.connect(_on_menu)
	_refresh()

func set_manager(m: MissionManager) -> void:
	manager = m
	if _painel != null:
		_bind(m)

func _bind(m: MissionManager) -> void:
	if not m.missao_iniciada.is_connected(_on_mudou):
		m.missao_iniciada.connect(_on_mudou)
	if not m.missao_atualizada.is_connected(_on_mudou):
		m.missao_atualizada.connect(_on_mudou)
	if not m.missao_concluida.is_connected(_on_concluida):
		m.missao_concluida.connect(_on_concluida)
	_refresh()

func _on_mudou(_id: String) -> void:
	_refresh()

func _on_menu(aberto: bool) -> void:
	_menu_aberto = aberto
	_refresh()

# Quando uma missão conclui: mostra o ✓ por um instante e depois volta ao normal
# (próxima missão ativa, ou some se não houver mais nenhuma).
func _on_concluida(id: String) -> void:
	if not _menu_aberto and manager != null and manager.missoes.has(id):
		var m: Mission = manager.missoes[id]
		_painel.visible = true
		_titulo.text = "✓ " + m.titulo
		_titulo.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
		_objetivo.text = "Missão concluída!"
		await get_tree().create_timer(2.0).timeout
	_refresh()

# ---------------- construção da interface ----------------
func _build() -> void:
	_painel = PanelContainer.new()
	# ancora no canto superior direito e cresce pra esquerda
	_painel.anchor_left = 1.0
	_painel.anchor_right = 1.0
	_painel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_painel.offset_left = -340
	_painel.offset_right = -16
	_painel.offset_top = 16
	_painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_painel.modulate = Color(1, 1, 1, 0.92)
	add_child(_painel)

	var margin := MarginContainer.new()
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(lado, 10)
	_painel.add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	margin.add_child(col)

	_titulo = Label.new()
	_titulo.add_theme_font_size_override("font_size", 14)
	_titulo.add_theme_color_override("font_color", Color(0.92, 0.85, 0.5))
	col.add_child(_titulo)

	_objetivo = Label.new()
	_objetivo.add_theme_font_size_override("font_size", 12)
	_objetivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objetivo.custom_minimum_size = Vector2(310, 0)
	col.add_child(_objetivo)

# ---------------- atualização ----------------
func _refresh() -> void:
	if _painel == null:
		return
	var m: Mission = _foco()
	if m == null or _menu_aberto:
		_painel.visible = false
		return
	_painel.visible = true
	_titulo.text = "◆ " + m.titulo
	_titulo.add_theme_color_override("font_color", Color(0.92, 0.85, 0.5))
	_objetivo.text = m.objetivo()

# missão em foco; se a de foco sumiu/concluiu, pega a primeira ainda ativa
func _foco() -> Mission:
	if manager == null:
		return null
	if manager.missoes.has(manager.foco):
		var mf: Mission = manager.missoes[manager.foco]
		if not mf.concluida:
			return mf
	for m in manager.lista():
		if not m.concluida:
			return m
	return null
