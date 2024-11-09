extends Node3D

# This will hold all rings in the path
var rings : Array = []
# Index of the currently visible ring
var current_ring_index : int = 0
# Signal to detect player passing through a ring
signal player_flew_through_ring

func _ready():
	# Initialize the rings array by gathering all the rings in the current scene
	rings = get_children().filter(func(node): return node.name.begins_with("ring"))
	
	# Make sure the first ring is visible and others are invisible
	update_ring_visibility()
	
	# Connect each ring's Area3D signal to this node
	for ring in rings:
		var area = ring.get_node("Area3D")  # Adjust the path if your Area3D is named differently
		if area:
			area.player_flew_through_ring.connect(_on_player_flew_through_ring)

func update_ring_visibility():
	for i in range(rings.size()):
		rings[i].visible = (i == current_ring_index)

func _on_player_flew_through_ring():
	# Increment the index to move to the next ring, wrapping around to 0 if at the end
	current_ring_index = (current_ring_index + 1) % rings.size()
	
	# Update visibility
	update_ring_visibility()
