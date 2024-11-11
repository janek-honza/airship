extends AnimationPlayer

func _ready():
	get_node("/root/main/player").throttle_both_engines.connect(animate_propellers)
	

func animate_propellers(throttle):
	speed_scale = (throttle)/100
	play("left_engine_1_propellerAction")
	print("left_engine_1_propellerAction")
