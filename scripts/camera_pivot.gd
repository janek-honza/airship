extends Node3D

var current_airship_type = ''

@onready var spring_arm = $XPivot/SpringArm3D
@onready var player = $".."

#Airship specific modifiers
var target_spring_length = 100.0
var aiming_offset = 25.0

func _process(delta):
	if player:
		# Check if the airship type has changed
		if current_airship_type != player.airship_type:
			current_airship_type = player.airship_type
			update_airship_specific_modifiers(current_airship_type)
	else:
		push_error("Player node or 'airship_type' variable not found!")

func update_airship_specific_modifiers(current_airship_type):
	match current_airship_type:
		'small':
			target_spring_length = 100.0
			aiming_offset = 25.0
		
		'medium':
			target_spring_length = 200.0
			aiming_offset = 55.0
		
		'big':
			target_spring_length = 300.0
			aiming_offset = 100.0
		
		_:
			print("\nERROR: Airship type ", current_airship_type, "not implemented in camera_pivot.gd")

func _physics_process(delta):
	#Adjust spring arm length to target length
	if abs(spring_arm.spring_length - target_spring_length) > 0.01:  # Avoids minor jitter/twitching
		spring_arm.spring_length = lerp(spring_arm.spring_length, target_spring_length, delta)
