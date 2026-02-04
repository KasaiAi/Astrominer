extends CharacterBody2D

@export var currentplanet: Node2D
@export var sprite: Sprite2D

const GRAVITY := 980.0
const MOVE_SPEED := 200.0
const JUMP_SPEED := 500.0
const GROUND_FRICTION := 12.0

func _physics_process(delta):
	var planetDirection = global_position.direction_to(currentplanet.global_position)
	var tangent = planetDirection.orthogonal()

	# Gravidade radial constante
	velocity += planetDirection * GRAVITY * delta

	# Movimento lateral (tangencial)
	var input := Input.get_axis("left", "right")
	if input != 0:
		velocity += tangent * input * MOVE_SPEED * delta
	elif is_on_floor():
		# Atrito só no chão (tangencial)
		var lateral := velocity.dot(tangent)
		velocity -= tangent * lateral * GROUND_FRICTION * delta

	# Pulo
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity -= planetDirection * JUMP_SPEED

	# Alinha o personagem com o planeta
	look_at(currentplanet.global_position)

	move_and_slide()
