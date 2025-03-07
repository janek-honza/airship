extends Node3D

@onready var spring_arm = $XPivot/SpringArm3D
@onready var player = $".."

#Airship specific modifiers
var target_spring_length = 100.0
var aiming_offset = 25.0 #How far does camera goes sideways when aiming

func _on_player_airship_type_switched() -> void:
	update_airship_specific_modifiers()

func update_airship_specific_modifiers():
	match player.airship_type:
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
			printerr("\nERROR: Airship type ", player.airship_type, "not implemented in camera_pivot.gd")

func _physics_process(delta):
	#Adjust spring arm length to target length
	if abs(spring_arm.spring_length - target_spring_length) > 0.01:  # Avoids minor jitter/twitching
		spring_arm.spring_length = lerp(spring_arm.spring_length, target_spring_length, delta)
	var offset_modifier = -1 #Changes aiming offset from right to left to always give good visibility of the target
	
	if Input.is_action_pressed("aiming"):
		if (self.position.x - offset_modifier * aiming_offset) > 0.01:
			self.position.x = lerp(self.position.x, -aiming_offset, delta*5)
	else:
		self.position.x = lerp(self.position.x, 0.0, delta*5)
