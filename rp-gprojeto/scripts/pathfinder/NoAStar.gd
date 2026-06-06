extends RefCounted
class_name NoAStar

var pos: Vector2i
var g: int
var h: int
var parent: NoAStar

func _init(p: Vector2i, custo_g: int, heurist: int, pai: NoAStar = null) -> void:
	pos = p
	g = custo_g
	h = heurist
	parent = pai

func f() -> int:
	return g + h

func atualizar_path(novo_g: int, novo_parent: NoAStar) -> void:
	g = novo_g
	parent = novo_parent
