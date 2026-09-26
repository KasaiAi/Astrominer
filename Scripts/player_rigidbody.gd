extends RigidBody2D

@export var currentplanet : StaticBody2D

@export var sprite: Sprite2D
@onready var raycast = $Downward
@onready var animator = $AnimationPlayer

# Falta implementar alguma simulação de atrito; PhysicsMaterial não tem efeito
# com Area2D como centro de gravidade

const MOVE_SPEED = 20
const JUMP_FORCE = -500

var direction : float
var planetDirection : Vector2
var force = Vector2.ZERO

#var max_air_speed := 180.0

func _physics_process(_delta):
	direction = Input.get_axis("left", "right")
	planetDirection = global_position.direction_to(currentplanet.global_position)
	
	# Movimentação
	if direction:
		force = planetDirection.orthogonal() * MOVE_SPEED * direction
	else:
		force = Vector2.ZERO
	
	# BUG: quanto o personagem está no ar, ele acelera até infinito e sai da órbita do planeta.
	# É preciso limitar a velocidade do apply_central_impulse. A solução é usar linear damp, mas
	# isso também reduz a velocidade de queda. >>Aumentar a gravidade de alguma forma<<
	
	# Pulo
	if Input.is_action_just_pressed("jump") and _on_floor():
		apply_central_impulse(planetDirection * JUMP_FORCE * 2)
	
	apply_central_impulse(force)
	
	# Acho que tem algum método nativo pro personagem não deslizar em rampas
	
	# Vira o personagem em direção ao planeta
	look_at(currentplanet.global_position)
	
	if Input.is_action_pressed("pickaxe"):
		pick_follow()

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

func _input(event):
	# Animação L+R
	if Input.is_action_pressed("left"):
#		scale.y = -1
		# Scale DEVERIA inverter o personagem inteiro, permitindo espelhar as animações, mas a
		# orientação é fixa por causa de look_at() (rotação também determina scale)
		sprite.flip_h = true
	elif Input.is_action_pressed("right"):
#		scale.y = 1
		sprite.flip_h = false
	#print(scale)
	
	if Input.is_action_pressed("pickaxe") and event is InputEventMouseButton:
		animator.play("mining")
	if Input.is_action_just_released("pickaxe"):
		animator.play("RESET")

func pick_follow():
	#$PickAxis.look_at(get_global_mouse_position())
	#$PickAxis.rotation_degrees += 90
	
	#var side_check = (int($PickAxis.rotation_degrees)+90)%360
	#if side_check < 0:
		#side_check += 360
	#if side_check >= 0 and side_check < 179:
		#animator.play("mining right")
	#elif side_check >= 180 and side_check < 359:
		#animator.play("mining left")
	
	var side_check = get_local_mouse_position().y
	if side_check < 0:
		$PickAxis.scale.y = 1
	elif side_check >= 0:
		$PickAxis.scale.y = -1

# Checa se personagem tá numa superfície
func _on_floor():
	if $Downward.is_colliding():
		return true
