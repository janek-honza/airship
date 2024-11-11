extends Node3D

var rings : Array = []
var current_ring_index : int = 0
signal player_flew_through_ring

func _ready():
	rings = get_children().filter(func(node): return node.name.begins_with("ring"))

	update_ring_visibility()
	
	for ring in rings:
		var area = ring.get_node("Area3D")
		if area:
			area.player_flew_through_ring.connect(_on_player_flew_through_ring)

func update_ring_visibility():
	for i in range(rings.size()):
		rings[i].visible = (i == current_ring_index)

func _on_player_flew_through_ring():
	current_ring_index = (current_ring_index + 1) % rings.size()
	
	update_ring_visibility()
