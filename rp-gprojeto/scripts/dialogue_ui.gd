extends CanvasLayer

@onready var dialogue_label = $Dialogo

var lines: Array[String] = []
var index: int = 0
var active: bool = false

func _ready():
	visible = false

func start_dialogue(new_lines: Array[String]):
	lines = new_lines
	index = 0
	active = true
	visible = true
	show_line()

func show_line():
	dialogue_label.text = lines[index]

func next():
	index += 1

	if index < lines.size():
		show_line()
	else:
		close()

func close():
	active = false
	visible = false
	lines.clear()
	index = 0

func is_active() -> bool:
	return active
