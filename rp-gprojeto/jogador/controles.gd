extends CharacterBody2D

const WALK_SPEED = 250.0
const RUN_SPEED = 500.0

var facing_direction = Vector2.DOWN

@onready var raycast = $RayCast2D

func _physics_process(_delta):

	if DialogueUI.is_active():
		velocity = Vector2.ZERO
		move_and_slide()
		return

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

	raycast.target_position = facing_direction * 64


func _input(event):
	if event.is_action_pressed("interact"):

		if DialogueUI.is_active():
			DialogueUI.next()
			return

		raycast.force_raycast_update()
				
		if raycast.is_colliding():
			var obj = raycast.get_collider()

			if obj and obj.has_method("interact"):
				obj.interact()
