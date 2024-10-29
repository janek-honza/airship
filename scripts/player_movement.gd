extends CharacterBody3D

@onready var Xpivot = $XPivot
@onready var Ypivot = $XPivot/YPivot
@onready var HUD = $HUD/Altitude_Throttle_Weight
@onready var visuals = $visuals

@export var sensitivity = 0.1
@export var mass = 0
@export var throttle = 0
@export var left_engine_speed = 0
@export var right_engine_speed = 0

#Vehicle specific modifiers
var engine_efficiency = 0.25
var base_mass = 9000
var max_mass_of_ballonets = 1000
var yaw_speed = 0.01
var max_roll_degree_in_yaw = 45 #Not really degrees, reaerch lerp() #Should be bigger for less stable airships and faster yaw_speed
var roll_level_speed = 1
var max_pitch_degree_in_pitch = 60 #Not really degrees, reaerch lerp()
var pitch_level_speed = 1

var fill_percent_ballonets = 40

var throttle_max = 100
var throttle_min = -50

var pitch_input = 0
var yaw_input = 0

var cargo_weight = 100
var displacment = 0

func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion:
		Xpivot.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		Ypivot.rotate_x(deg_to_rad(event.relative.y * sensitivity))
	
	if Input.is_action_pressed("throttle_up") and throttle < throttle_max:
		throttle = throttle + 1
	
	if Input.is_action_pressed("throttle_down") and throttle > throttle_min:
		throttle = throttle - 1
	
	pitch_input = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")
	
	yaw_input = Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right")
	
	if Input.is_action_pressed("inflate_ballonet") and fill_percent_ballonets < 100:
		fill_percent_ballonets = fill_percent_ballonets + 1
	
	if Input.is_action_pressed("deflate_ballonet") and fill_percent_ballonets > 0:
		fill_percent_ballonets = fill_percent_ballonets - 1

func _process(delta):
	mass = base_mass + cargo_weight + max_mass_of_ballonets * fill_percent_ballonets / 100
	displacment = -self.global_transform.origin.y + 50 + base_mass + max_mass_of_ballonets * 0.5
	HUD.text = "Altitude: " + str(self.global_transform.origin.y)+ "\nThrottle: " + str(throttle) + "\nMass: " + str(mass)

func _physics_process(delta: float):
	var engine_direction = global_transform.basis.z
	
	velocity = engine_direction * throttle * engine_efficiency + global_transform.basis.y * (displacment - mass)/10
	
	self.rotation.x = lerp(self.rotation.x, -float(pitch_input) * max_pitch_degree_in_pitch/360 * (self.velocity.z / 10), pitch_level_speed * delta)
	
	self.rotation.y = self.rotation.y + yaw_input * yaw_speed
	visuals.rotation.z = lerp(visuals.rotation.z, -float(yaw_input) * max_roll_degree_in_yaw/360, roll_level_speed * delta)
	
	move_and_slide()
