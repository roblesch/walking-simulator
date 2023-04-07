extends CharacterBody3D

@onready
var player = get_parent().get_node("Player")
@onready
var base_height = float(position.y)

var rng = RandomNumberGenerator.new()
var t = 0
var orbit_dir = 1

var ORBIT_RADIUS = 2
const ORBIT_SPEED = 0.2
const FLOAT_SPEED = 1
const NOD_MAG_X = 0.5
const NOD_MAG_Y = 0.3
const NOD_SPEED = 3
const BOB_SPEED = 2
const BOB_DIST = 0.2
const RETREAT_SPEED = 1

func _ready():
	t = rng.randf()
	ORBIT_RADIUS += rng.randf_range(0, 2)
	orbit_dir *= -1 if randi_range(0,1) == 0 else 1
	$AnimationPlayer.play("Cube001_0Action")
	$AnimationPlayer.seek(rng.randf_range(0, 1), true)

func player_head():
	return player.position + Vector3.UP * 0.5

func _physics_process(delta):
	# Stare at the player
	var look_pos = player_head()
	look_pos.x += cos(t * NOD_SPEED) * NOD_MAG_X
	look_pos.y += sin(t * NOD_SPEED) * NOD_MAG_Y
	$Mesh.look_at(look_pos, Vector3.UP)

	# Switch directions when the player shimmies
	if Input.is_action_just_pressed("moveLeft") or Input.is_action_just_pressed("moveRight"):
		orbit_dir *= -1

	# Move towards the player's orbit
	var target_pos = player_head() + (Vector3.FORWARD * ORBIT_RADIUS).rotated(Vector3.UP, t * ORBIT_SPEED)
	var dir_to_target = (target_pos - position).normalized()
	velocity.x = dir_to_target.x * FLOAT_SPEED
	velocity.z = dir_to_target.z * FLOAT_SPEED

	# Avoid colliding with the player
	if (player_head() - position).length() < ORBIT_RADIUS * 2 / 3:
		var dir_away_player = (position - player_head()).normalized()
		velocity.x = dir_away_player.x * FLOAT_SPEED * RETREAT_SPEED
		velocity.z = dir_away_player.z * FLOAT_SPEED * RETREAT_SPEED

	# Bob
	var bob_height = base_height + sin(t * BOB_SPEED) * BOB_DIST
	position.y = bob_height

	# Increment time
	t += delta * orbit_dir

	move_and_slide()
