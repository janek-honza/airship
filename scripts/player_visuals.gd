extends Node3D

func _process(_delta):
	if Input.is_action_pressed("switch_airship_type"):
		update_visuals()


func update_visuals():
	var player = get_parent()
	if player.airship_type == 'small':
		$small.visible = true
		$medium.visible = false
		$big.visible = false
	
	if player.airship_type == 'medium':
		$small.visible = false
		$medium.visible = true
		$big.visible = false
	
	if player.airship_type == 'big':
		$small.visible = false
		$medium.visible = false
		$big.visible = true
