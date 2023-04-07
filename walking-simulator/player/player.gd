extends CharacterBody3D

@onready var gun_ray = $Head/Camera3d/RayCast3d as RayCast3D
@onready var cam = $Head/Camera3d as Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const STANDING_HEIGHT = 0.5
const CROUCHING_HEIGHT = 0.2

var mouse_sens = 400
var mouse_relative_x = 0
var mouse_relative_y = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Captures mouse and stops rgun from hitting yourself
	gun_ray.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Bind alt
	var key_alt = InputEventKey.new()
	key_alt.physical_keycode = KEY_ALT
	InputMap.add_action("key_alt")
	InputMap.action_add_event("key_alt", key_alt)

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Determine movement dir
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func mouse_captured():
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

func swap_mouse_mode():
	if mouse_captured():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			# Quit on Esc
			KEY_ESCAPE:
				get_tree().quit()
			# Crouch with ctrl
			KEY_CTRL:
				get_node("Head").position.y = CROUCHING_HEIGHT
				get_node("HeadCollider").disabled = true

	if not Input.is_key_pressed(KEY_CTRL):
		get_node("Head").position.y = STANDING_HEIGHT
		get_node("HeadCollider").disabled = false

	# Release mouse with alt
	if Input.is_action_just_pressed("key_alt"):
		swap_mouse_mode()

	# Rotate camera with mouse
	elif event is InputEventMouseMotion and mouse_captured():
		rotation.y -= event.relative.x / mouse_sens
		$Head/Camera3d.rotation.x -= event.relative.y / mouse_sens
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

	# if Input.is_action_just_pressed("Shoot"):
		# This doesn't really work, the velocity gets overriden by skull physics.
		# The skull can accumulate velocity (acceleration) but that's hard...
		# if "Skull" in gunRay.get_collider().get_name():
			# var skull = gunRay.get_collider()
			# var dir_away_player = (skull.position - position).normalized()
			# skull.velocity.x += dir_away_player.x * 2
			# skull.velocity.z += dir_away_player.z * 2
