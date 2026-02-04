extends RigidBody2D

@export var currentplanet : StaticBody2D

@export var sprite: Sprite2D
@export var raycast : RayCast2D

const MOVE_SPEED = 10
const JUMP_FORCE = 400

var direction : float
var planetDirection : Vector2
var force = Vector2.ZERO

#var max_air_speed := 180.0

func _physics_process(delta):
	direction = Input.get_axis("left", "right")
	planetDirection = global_position.direction_to(currentplanet.global_position)
	
	# Movimentação
	# BUG: quanto o personagem está no ar, ele acelera até infinito e sai da órbita do planeta.
	# É preciso limitar a velocidade do apply_central_impulse
	if direction:
		force = planetDirection.orthogonal() * MOVE_SPEED * direction
	else:
		force = Vector2.ZERO
	
	# Pulo
	if Input.is_action_just_pressed("jump") and _on_floor():
		apply_central_impulse(-planetDirection * JUMP_FORCE)
	
#	clamp(force, 0, 500)
	apply_central_impulse(force)
	
	# Vira o personagem em direção ao planeta
	look_at(currentplanet.global_position)

#func _integrate_forces(state):
#	planetDirection = global_position.direction_to(currentplanet.global_position)
#	var v = state.linear_velocity
#
#	var radial_speed = v.dot(planetDirection)
#
#	if _on_floor():
#		if radial_speed < 0:
#			v -= planetDirection * radial_speed
#	else:
#		# No ar: limita apenas a saída
#		if radial_speed < -max_air_speed:
#			v -= planetDirection * (radial_speed + max_air_speed)
#
#	state.linear_velocity = v

func _input(_event):
	# Animação L+R
	if Input.is_action_pressed("left"):
		sprite.flip_h = true
	elif Input.is_action_pressed("right"):
		sprite.flip_h = false

# Checa se personagem tá numa superfície
func _on_floor():
	if raycast.is_colliding():
		return true
