extends GPUParticles3D

func _process(_delta):
	# Update the shader parameter with the player's position
	process_material.set_shader_parameter("PLAYER_POSITION", get_parent().global_position)
