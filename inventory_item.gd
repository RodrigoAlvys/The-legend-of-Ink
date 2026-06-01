class_name InventoryItem
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var item_type: String = "quest"
@export var description: String = ""
@export var value: int = 0
@export var quantity: int = 1
@export var max_stack: int = 1
@export var stackable: bool = false


func can_stack_with(other: InventoryItem) -> bool:
	return other != null and stackable and other.stackable and id == other.id


func has_stack_space() -> bool:
	return stackable and quantity < max_stack


func remaining_stack_space() -> int:
	if not stackable:
		return 0

	return max_stack - quantity


func copy_with_quantity(new_quantity: int) -> InventoryItem:
	var copy := duplicate(true) as InventoryItem
	copy.quantity = max(0, new_quantity)
	return copy
