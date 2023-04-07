extends RigidBody3D

@onready
var player = get_parent().get_node("Player")
@onready
var original_basis = basis

const TRAVEL_SPEED = .05

func player_position():
	return player.position

func _physics_process(_delta):

	var target_pos = player_position()
	var dir_to_target = target_pos - position
	# Move towards the player if not seen
	if not $Visibility.is_on_screen() and dir_to_target.length() > 1:

		dir_to_target = dir_to_target.normalized()
		position.x += dir_to_target.x * TRAVEL_SPEED
		position.z += dir_to_target.z * TRAVEL_SPEED

		basis = original_basis

		# Face player using black magic
		var angel_facing = Vector3(basis.z.x, 0, basis.z.z,).normalized()
		var to_player = (Vector3(player.position.x, 0, player.position.z) - Vector3(position.x, 0, position.z)).normalized()
		basis = Basis(Quaternion(angel_facing, to_player))
