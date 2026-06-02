extends CharacterBody2D

const WALK_SPEED = 250.0
const RUN_SPEED = 500.0

func _physics_process(delta):
	var direction = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	var speed = WALK_SPEED

	if Input.is_key_pressed(KEY_SHIFT):
		speed = RUN_SPEED

	velocity = direction * speed
	move_and_slide()
