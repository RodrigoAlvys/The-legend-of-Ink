extends CharacterBody2D

const WALK_SPEED = 250.0
const RUN_SPEED = 500.0

var facing_direction = Vector2.DOWN

@onready var raycast = $RayCast2D

func _physics_process(delta):
	var direction = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	if direction != Vector2.ZERO:
		facing_direction = direction.normalized()

	var speed = WALK_SPEED

	if Input.is_key_pressed(KEY_SHIFT):
		speed = RUN_SPEED

	velocity = direction * speed
	move_and_slide()

	# Mantém o RayCast apontando para frente
	raycast.target_position = facing_direction * 64


func _input(event):
	if event.is_action_pressed("interact"):
		if raycast.is_colliding():
			var obj = raycast.get_collider()

			if obj.has_method("interact"):
				obj.interact()
