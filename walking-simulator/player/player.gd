extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
@export var _bullet_scene : PackedScene

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_BULLET_HOLES = 30

const STANDING_HEIGHT = 0.5
const CROUCHING_HEIGHT = 0.2

var mouseSens = 400
var mouse_relative_x = 0
var mouse_relative_y = 0
var bulletHoles = []

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	gunRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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

	# Rotate camera with mouse
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouseSens
		$Head/Camera3d.rotation.x -= event.relative.y / mouseSens
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

	# Create a bullet hole on the surface the player "shoots"
	if Input.is_action_just_pressed("Shoot"):
		# No hit, no hole
		if not gunRay.is_colliding():
			return

		# Pop and remove oldest bullet holes
		if bulletHoles.size() > MAX_BULLET_HOLES:
			var bulletToRemove = bulletHoles.pop_front()
			get_parent().remove_child(bulletToRemove)

		# Instantiate and orient the bullet hole texture
		var bulletInst = _bullet_scene.instantiate() as Node3D
		bulletInst.set_as_top_level(true)
		get_parent().add_child(bulletInst)
		bulletHoles.push_back(bulletInst)
		bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3

		# If the shot hits floor or ceiling, use FORWARD as up
		bulletInst.look_at((gunRay.get_collision_point()+gunRay.get_collision_normal()),
			Vector3.UP if abs(gunRay.get_collision_normal().dot(Vector3.UP)) < 1
			else Vector3.FORWARD)

		# This doesn't really work, the velocity gets overriden by skull physics.
		# The skull can accumulate velocity (acceleration) but that's hard...
		if "Skull" in gunRay.get_collider().get_name():
			var skull = gunRay.get_collider()
			var dir_away_player = (skull.position - position).normalized()
			skull.velocity.x += dir_away_player.x * 2
			skull.velocity.z += dir_away_player.z * 2
