extends CharacterBody3D

@onready var Xpivot = $XPivot
@onready var Ypivot = $XPivot/YPivot
@onready var HUD = $HUD/Altitude_Throttle_Mass
@onready var visuals = $visuals
@onready var Debug = $HUD/Debug

@export var sensitivity = 0.1

@export_enum ("small", "medium", "big") var airship_type = "small"
const AIRSHIP_TYPES = ["small", "medium", "big"] #It would be more optimal to define the list of airship types only one, but I'm not sure how to do it rn, to be fixed in the future

var mass = 0
var throttle = 0
var left_engine_rpm = 0 #To be used in animation player
var right_engine_rpm = 0 #To be used in animation player

#Airship specific modifiers
var engine_efficiency = 0.25
var base_mass = 9000
var max_mass_of_ballonets = 1000
var yaw_speed = 0.01
var max_roll_in_yaw = 45 #Should be bigger for less stable airships and faster yaw_speed
var roll_level_speed = 1
var max_pitch_in_pitch = 60
var pitch_level_speed = 1
var spring_length = 100
var sidewind_modifier = 1 #How much stronger is wind from the side than from the front, changes with sin(degrees)

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

var can_switch = true #to prevent bugs from rapidly switching

func _input(event):
	if event is InputEventMouseMotion:
		Xpivot.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		Ypivot.rotate_x(deg_to_rad(event.relative.y * sensitivity))
	
	if Input.is_action_pressed("throttle_up") and throttle < throttle_max:
		throttle = min(throttle + 1, 100)
	
	if Input.is_action_pressed("throttle_down") and throttle > throttle_min:
		throttle = max(throttle - 1, -50)
	
	pitch_input = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")
	
	yaw_input = Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right")
	
	if Input.is_action_pressed("inflate_ballonet"):
		target_fill_percent_ballonets = min(target_fill_percent_ballonets + 1, 100)
	
	if Input.is_action_pressed("deflate_ballonet"):
		target_fill_percent_ballonets = max(target_fill_percent_ballonets - 1, 0)
	
	if Input.is_action_pressed("switch_airship_type") and can_switch:
		cycle_airship_type()
		can_switch = false

	if not Input.is_action_pressed("switch_airship_type"):
		can_switch = true

func _process(_delta):
	displacment = -self.global_transform.origin.y + 40 + base_mass + max_mass_of_ballonets * 0.5
	
	HUD.text = "Altitude: " + str(snapped(self.global_transform.origin.y, 1))+ "\nThrottle: " + str(throttle) + "\nMass: " + str(snapped(mass, 1))
	
	Debug.text = "Debug:" + "\n" + str(target_fill_percent_ballonets) + "\n" + str(snapped(fill_percent_ballonets, 0.1)) + "\n" + str(snapped(relative_speed_forward, 1)) + "\n" + str(snapped(engine_speed, 1))

func _physics_process(delta):
	var engine_direction = global_transform.basis.z #in other airships engine direction can be changed
	target_engine_speed = throttle * engine_efficiency
	relative_speed_forward = velocity.dot(global_transform.basis.z)
	if engine_speed <= target_engine_speed:
		engine_speed = min(engine_speed + delta * 10000 / mass, target_engine_speed)
	else:
		engine_speed = max(engine_speed - delta * 10000 / mass, target_engine_speed)
	
	if fill_percent_ballonets <= target_fill_percent_ballonets:
		fill_percent_ballonets = min(fill_percent_ballonets + delta, target_fill_percent_ballonets)
	else:
		fill_percent_ballonets = max(fill_percent_ballonets - delta, target_fill_percent_ballonets)
	mass = base_mass + cargo_weight + max_mass_of_ballonets * fill_percent_ballonets/100
	
	#Sum of 3 components of velocity:
	# - engines
	# - displacment/buoyancy
	# - wind force
	velocity = (engine_direction * engine_speed
	+ Vector3.UP * (displacment - mass) / 10
	+ global.wind_direction * (sidewind_modifier*(global.wind_direction.angle_to(global_transform.basis.z)) + 1))
	
	self.rotation.x = lerp(self.rotation.x, -float(pitch_input) * max_pitch_in_pitch/360 * (relative_speed_forward / 10), pitch_level_speed * delta)
	
	#While rotating on y axis (yaw) there is a small and only visual rotation on z axis (roll) to simulate aerodynamics of yaw  
	self.rotation.y = self.rotation.y + yaw_input * yaw_speed * (5 / (abs(relative_speed_forward)+5))
	visuals.rotation.z = lerp(visuals.rotation.z, -float(yaw_input) * max_roll_in_yaw/360, roll_level_speed * delta)
	
	move_and_slide()

func adjust_airship_specific_modifiers():
	if airship_type == 'small':
		engine_efficiency = 0.25
		base_mass = 9000
		max_mass_of_ballonets = 1000
		yaw_speed = 0.01
		max_roll_in_yaw = 45
		roll_level_speed = 1
		max_pitch_in_pitch = 60
		pitch_level_speed = 1
		sidewind_modifier = 1
	
	if airship_type == 'medium':
		engine_efficiency = 0.75
		base_mass = 20000
		max_mass_of_ballonets = 2000
		yaw_speed = 0.01
		max_roll_in_yaw = 45
		roll_level_speed = 1
		max_pitch_in_pitch = 60
		pitch_level_speed = 1
		sidewind_modifier = 2
	
	if airship_type == 'big':
		engine_efficiency = 1.25
		base_mass = 45000
		max_mass_of_ballonets = 5000
		yaw_speed = 0.01
		max_roll_in_yaw = 45
		roll_level_speed = 1
		max_pitch_in_pitch = 60
		pitch_level_speed = 1
		sidewind_modifier = 3

func cycle_airship_type():
		var current_index = AIRSHIP_TYPES.find(airship_type)
		# Calculate the next index, cycling back to 0 if past max
		var next_index = (current_index + 1) % AIRSHIP_TYPES.size()
		airship_type = AIRSHIP_TYPES[next_index]
		adjust_airship_specific_modifiers()
		print("Airship type switched to: ", airship_type)
