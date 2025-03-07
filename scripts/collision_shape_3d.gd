extends CollisionShape3D

@onready var player = $".."


func _on_player_airship_type_switched() -> void:
	match player.airship_type:
		'small':
			shape.size = Vector3(40, 42, 79)
			self.position = Vector3(0, 0, 0)
		
		'medium':
			shape.size = Vector3(67, 56, 141)
			self.position = Vector3(0, 0, 0)
		
		'big':
			shape.size = Vector3(67, 60, 202)
			self.position = Vector3(0, -2, 0)
		
		_:
			printerr("\nERROR: Airship type ", player.airship_type, "not implemented in collision_shape_3d.gd")
