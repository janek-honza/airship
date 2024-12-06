extends SpringArm3D

const spring_arm_lengths_from_airship_type = {"small": 100.0, "medium": 200.0, "big": 300.0}

var current_airship_type: String = ""
var target_length: float = 100.0

func _process(delta):
	# Get the player node (assumed to be the great grandparent)
	var player = get_parent().get_parent().get_parent()
	if player:
		# Check if the airship type has changed
		if current_airship_type != player.airship_type:
			current_airship_type = player.airship_type
			target_length = spring_arm_lengths_from_airship_type[current_airship_type]
	else:
		push_error("Player node or 'airship_type' variable not found!")
	
	if abs(spring_length - target_length) > 0.01:  # Avoid minor jitter
		spring_length = lerp(spring_length, target_length, delta)
