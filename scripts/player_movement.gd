extends CharacterBody3D

@onready var Xpivot = $XPivot
@onready var Ypivot = $XPivot/YPivot
@onready var HUD = $HUD/Altitude_Throttle_Mass
@onready var visuals = $visuals
@onready var airship_type = "floater"
@onready var Debug = $HUD/Debug
#@onready var wind = get_node("../wind_visuals") Not working direct node access, the line below is a workaround to be removed when this is fixed.
#var wind_direction: Vector3 = wind.wind_direction
var wind_direction: Vector3 = Vector3(1, 0, -1)

@export var sensitivity = 0.1
@export var mass = 0
@export var throttle = 0
@export var left_engine_rpm = 0 #To be used in animation player
@export var right_engine_rpm = 0

#Vehicle specific modifiers
var engine_efficiency = 0.25
var base_mass = 9000
var max_mass_of_ballonets = 1000
var yaw_speed = 0.01
var max_roll_degree_in_yaw = 45 #Not really degrees, reaerch lerp() #Should be bigger for less stable airships and faster yaw_speed
var roll_level_speed = 1
var max_pitch_degree_in_pitch = 60 #Not really degrees, reaerch lerp()
var pitch_level_speed = 1
var spring_length = 100

var fill_percent_ballonets = 40
var target_fill_percent_ballonets = 40

var throttle_max = 100
var throttle_min = -50

var pitch_input = 0
var yaw_input = 0

var cargo_weight = 100
var displacment = 0
var target_engine_speed = 0
var engine_speed = 0
var relative_speed_forward = velocity.dot(transform.basis.z)

func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion:
		Xpivot.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		Ypivot.rotate_x(deg_to_rad(event.relative.y * sensitivity))
	
	if Input.is_action_pressed("throttle_up") and throttle < throttle_max:
		throttle = min(throttle + 1, 100)
	
	if Input.is_action_pressed("throttle_down") and throttle > throttle_min:
		throttle = max(throttle - 1, 0)
	
	pitch_input = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")
	
	yaw_input = Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right")
	
	if Input.is_action_pressed("inflate_ballonet"):
		target_fill_percent_ballonets = min(target_fill_percent_ballonets + 1, 100)
	
	if Input.is_action_pressed("deflate_ballonet"):
		target_fill_percent_ballonets = max(target_fill_percent_ballonets - 1, 0)

func _process(delta):
	displacment = -self.global_transform.origin.y + 40 + base_mass + max_mass_of_ballonets * 0.5
	HUD.text = "Altitude: " + str(snapped(self.global_transform.origin.y, 1))+ "\nThrottle: " + str(throttle) + "\nMass: " + str(snapped(mass, 1))
	Debug.text = "Debug:" + "\n" + str(target_fill_percent_ballonets) + "\n" + str(fill_percent_ballonets) + "\n" + str(snapped(relative_speed_forward, 1)) + "\n" + str(snapped(engine_speed, 1))

func _physics_process(delta):
	var engine_direction = global_transform.basis.z #in other airships engine direction can be changed
	target_engine_speed = throttle * engine_efficiency
	relative_speed_forward = velocity.dot(global_transform.basis.z)
	if engine_speed <= target_engine_speed:
		engine_speed = min(engine_speed + delta*10000/mass, target_engine_speed)
	else:
		engine_speed = max(engine_speed - delta*10000/mass, target_engine_speed)
	
	if fill_percent_ballonets <= target_fill_percent_ballonets:
		fill_percent_ballonets = min(fill_percent_ballonets + delta, target_fill_percent_ballonets)
	else:
		fill_percent_ballonets = max(fill_percent_ballonets - delta, target_fill_percent_ballonets)
	mass = base_mass + cargo_weight + max_mass_of_ballonets * fill_percent_ballonets/100
	
	velocity = engine_direction * engine_speed + Vector3.UP * (displacment - mass)/10 + wind_direction * (sin(wind_direction.angle_to(global_transform.basis.z)) + 1)
	
	self.rotation.x = lerp(self.rotation.x, -float(pitch_input) * max_pitch_degree_in_pitch/360 * (relative_speed_forward / 10), pitch_level_speed * delta)
	
	self.rotation.y = self.rotation.y + yaw_input * yaw_speed * (5 / (abs(relative_speed_forward)+5))
	visuals.rotation.z = lerp(visuals.rotation.z, -float(yaw_input) * max_roll_degree_in_yaw/360, roll_level_speed * delta)
	
	move_and_slide()
