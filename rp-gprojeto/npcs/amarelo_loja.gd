extends CharacterBody2D

# Itens que este mercador vende (ids do ItemDatabase).
@export var estoque: Array[String] = [
	"potion_s", "potion_l", "sword_rusty", "armor_leather", "ring_ink", "elixir_vigor"
]

func interact():
	if Game.shop_ui != null and not Game.shop_ui.aberta():
		Game.shop_ui.abrir(estoque)
