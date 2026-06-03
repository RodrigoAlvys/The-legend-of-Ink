class_name Stats
extends Resource

@export var health: float = 100.0
@export var max_health: float = 100.0
@export var speed: float = 200.0
@export var damage: float = 10.0

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		health = 0
		emit_signal("died")

func heal(amount: float) -> void:
	health += amount
	if health > max_health:
		health = max_health

func is_dead() -> bool:
	return health <= 0

signal died
