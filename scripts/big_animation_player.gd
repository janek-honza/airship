extends AnimationPlayer

func _ready():
	pass
	

func animate_propellers(throttle):
	speed_scale = (throttle)/100
	play("left_engine_1_propellerAction")
	print("left_engine_1_propellerAction")
