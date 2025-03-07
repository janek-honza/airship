extends Node3D
@onready var player = $".."

var small = load("res://scenes/small.tscn")
var medium = load("res://scenes/medium.tscn")
var big = load("res://scenes/big.tscn")

func _on_player_airship_type_switched() -> void:
	
	for child in get_children():
		child.queue_free()
		
	match player.airship_type:
		'small':
			add_child(small.instantiate())
		
		'medium':
			add_child(medium.instantiate())
		
		'big':
			add_child(big.instantiate())
		
		_:
			printerr("\nERROR: Airship type ", player.airship_type, "not implemented in player_visuals.gd")
