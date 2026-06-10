# NotificationUI.gd
# Notificações pequenas e temporárias (toasts) no rodapé da tela. Usada pela
# Coleta de Itens (US-05): "Coletado: X" / "Inventário cheio!". RNF: pequenas,
# pra não poluir a tela; cada aviso some sozinho após alguns segundos.
class_name NotificationUI
extends CanvasLayer

@export var duracao: float = 2.0      # segundos que cada aviso fica na tela

var _box: VBoxContainer

func _ready() -> void:
	_box = VBoxContainer.new()
	_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_box.offset_bottom = -24
	_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_box.add_theme_constant_override("separation", 4)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)

func show_msg(texto: String) -> void:
	if _box == null:
		return
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.modulate = Color(1, 1, 1, 0.95)

	var margin := MarginContainer.new()
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(lado, 6)
	panel.add_child(margin)

	var lbl := Label.new()
	lbl.text = texto
	lbl.add_theme_font_size_override("font_size", 13)
	margin.add_child(lbl)

	_box.add_child(panel)

	# fica "duracao" segundos, depois faz fade e se remove sozinho
	var tw := create_tween()
	tw.tween_interval(duracao)
	tw.tween_property(panel, "modulate:a", 0.0, 0.4)
	tw.tween_callback(panel.queue_free)
