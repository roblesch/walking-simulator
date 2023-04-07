extends CharacterBody3D

@onready
var player = get_parent().get_node("Player")

const TRAVEL_SPEED = 0.5

var isSeen = true

func player_position():
	return player.position
	
func _physics_process(_delta):
	
	# Move towards the player's orbit
	if not isSeen:
		var target_pos = player_position() + (Vector3.FORWARD)
		var dir_to_target = (target_pos - position).normalized()
		velocity.x = dir_to_target.x * TRAVEL_SPEED
		velocity.z = dir_to_target.z * TRAVEL_SPEED
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()

func _on_player_looking_at_angel(isTrue):
	isSeen = isTrue
