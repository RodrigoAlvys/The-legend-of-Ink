# DroppedItem.gd
# Um item largado/posicionado no chão do mapa (US-05 - Coleta de Itens).
# Quando o player está em cima e aperta a tecla de coleta (G), o item vai para
# o inventário (se houver espaço) e some do mapa. Sem espaço => avisa e não pega.
class_name DroppedItem
extends Area2D

@export var item_id: String = "potion_s"    # qual item este do chão representa
@export var quantidade: int = 1
@export var collect_key: int = KEY_G         # tecla de atalho da coleta

@onready var _sprite: Sprite2D = $Sprite2D

var _player_perto: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_atualizar_visual()

# se o item tiver ícone próprio, usa; senão mantém o sprite padrão da cena
func _atualizar_visual() -> void:
	var item := ItemDatabase.get_item(item_id)
	if item != null and item.icon != null and _sprite != null:
		_sprite.texture = item.icon

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_perto = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_perto = false

func _unhandled_input(event: InputEvent) -> void:
	if not _player_perto:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == collect_key:
		_coletar()
		get_viewport().set_input_as_handled()

func _coletar() -> void:
	var item := ItemDatabase.get_item(item_id)
	if item == null or Game.inventory == null:
		return
	# RF-05c: sem espaço => notifica e não coleta
	if not _tem_espaco(item):
		Game.notify("Inventário cheio!")
		return
	Game.inventory.add_item(item, quantidade)
	# RF-05b: notifica qual item foi pego
	var qtd_txt: String = (" x%d" % quantidade) if quantidade > 1 else ""
	Game.notify("Coletado: %s%s" % [item.name, qtd_txt])
	queue_free()   # some do mapa após a coleta

# cabe se já existe pilha do mesmo item (empilhável) ou se há slot livre
func _tem_espaco(item: Item) -> bool:
	if item.stackable and Game.inventory.has_item(item):
		return true
	return Game.inventory.slots.size() < Inventory.MAX_SLOTS
