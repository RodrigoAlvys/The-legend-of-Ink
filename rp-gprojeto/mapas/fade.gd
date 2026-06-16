extends CanvasLayer

@onready var rect = $ColorRect

func fade_out(time := 0.1):
	rect.visible = true
	rect.modulate.a = 0
	var t = create_tween()
	t.tween_property(rect, "modulate:a", 1.0, time)
	await t.finished

func fade_in(time := 0.1):
	var t = create_tween()
	t.tween_property(rect, "modulate:a", 0.0, time)
	await t.finished
	rect.visible = false
