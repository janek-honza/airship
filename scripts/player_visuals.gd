extends Node3D
@onready var player = $".."

var current_airship_type = 'small'

func _process(_delta):
	if player:
		# Check if the airship type has changed
		if current_airship_type != player.airship_type:
			current_airship_type = player.airship_type
			update_visuals()
	else:
		printerr("Player node or 'airship_type' variable not found!")

func update_visuals():
	match player.airship_type:
		'small':
			$small.visible = true
			$medium.visible = false
			$big.visible = false
		
		'medium':
			$small.visible = false
			$medium.visible = true
			$big.visible = false
		
		'big':
			$small.visible = false
			$medium.visible = false
			$big.visible = true
		
		_:
			printerr("Airship type '", player.airship_type, "' not implemented in player_visuals.gd")
