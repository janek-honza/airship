extends Area3D

@export var ring_id : int  # To identify which ring it is
signal player_flew_through_ring

func _ready():
	# Connect the body_entered signal to our local method
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Body entered: ", body.name)
	player_flew_through_ring.emit()
	if body.is_in_group("player"):
		print("Player detected!")
		player_flew_through_ring.emit()
