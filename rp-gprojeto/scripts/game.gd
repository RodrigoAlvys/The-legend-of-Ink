extends Node

var spawn_temp: StringName = ""

# Inventário
var inventory: Inventory
var inventory_ui: InventoryUI

func _ready() -> void:
	inventory = Inventory.new()
	inventory.set_coins(100)
	
	# itens de teste — Vai ser removido quando a Coleta (US-05) estiver pronta
	inventory.add_item(ItemDatabase.get_item("potion_s"), 3)
	inventory.add_item(ItemDatabase.get_item("sword_rusty"), 1)
	inventory.add_item(ItemDatabase.get_item("armor_leather"), 1)

	# cria a tela e pendura no Game (assim ela aparece em qualquer mapa)
	inventory_ui = InventoryUI.new()
	inventory_ui.inventory = inventory
	add_child(inventory_ui)
