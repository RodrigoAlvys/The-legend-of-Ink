extends Node

const DROPPED_ITEM := preload("res://inventory/DroppedItem.tscn")

var spawn_temp: StringName = ""

# Inventário
var inventory: Inventory
var inventory_ui: InventoryUI

# Notificações (coleta de itens, etc.)
var notifications: NotificationUI

# missões 
var missions: MissionManager
var mission_menu: MissionMenu
var mission_hud: MissionHUD

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

	# notificações (toasts) + coleta de itens
	notifications = NotificationUI.new()
	add_child(notifications)
	# ao largar um item do inventário, ele aparece no chão pra ser coletado
	inventory.item_dropped.connect(_on_item_dropped)

	missions = MissionManager.new()
	missions.inventory = inventory      # pra entregar recompensa no inventário
	mission_menu = MissionMenu.new()
	mission_menu.manager = missions
	add_child(mission_menu)

	# rastreador na tela (canto superior direito)
	mission_hud = MissionHUD.new()
	mission_hud.manager = missions
	mission_hud.menu = mission_menu
	add_child(mission_hud)
	missions.iniciar("despertar")

# atalho usado por qualquer parte do jogo pra mostrar um aviso pequeno na tela
func notify(texto: String) -> void:
	if notifications != null:
		notifications.show_msg(texto)

# quando o jogador larga um item pelo inventário, cria o item no chão (no mapa
# atual, na posição do player) pra poder ser coletado de volta.
func _on_item_dropped(item: Item, count: int) -> void:
	var player := get_tree().get_first_node_in_group("player")
	var cena := get_tree().current_scene
	if player == null or cena == null:
		return
	var chao := DROPPED_ITEM.instantiate()
	chao.item_id = item.id
	chao.quantidade = count
	# coloca dentro do nó "Entidades" (que tem y_sort) pra renderizar na
	# profundidade certa junto com os personagens; se não houver, cai no raiz
	var pai: Node = cena.find_child("Entidades", true, false)
	if pai == null:
		pai = cena
	pai.add_child(chao)
	chao.global_position = player.global_position
