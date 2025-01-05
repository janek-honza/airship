extends CharacterBody3D

@onready var Ypivot = $YPivot
@onready var Xpivot = $YPivot/XPivot
@onready var HUD = $HUD/Altitude_Throttle_Mass
@onready var visuals = $visuals
@onready var Debug = $HUD/Debug

@export var sensitivity = 0.1

@export_enum ("small", "medium", "big") var airship_type = "small"
const AIRSHIP_TYPES = ["small", "medium", "big"] #The same list is mirrored in camera_pivot and player_visuals scripts.
#It would be more optimal to define the list of airship types only once, but I'm not sure how to do it rn, to be fixed in the future

#Airship specific modifiers, initialized for AIRSHIP_TYPE == small, but updated in func ready()
var engine_efficiency = 0.35
var base_mass = 9000
var lift_modifier = 0.01
var yaw_speed = 0.75
var max_roll_in_yaw = 45 #~half of maximum roll during yaw in degrees. Should be bigger for less stable airships and faster yaw_speed
var roll_level_speed = 1 #How fast roll returns to level after yaw pushing it out of level
var max_pitch_in_pitch = 0.5 #maximum pitch in radians
var min_pitch_in_pitch = -0.5 #minimum pitch in radians
var pitch_speed = 1
var sidewind_modifier = 1 #How much stronger is wind from the side than from the front, changes with sin(degrees)
var max_altitude = 500
var max_climb_speed = 5
var climb_acceleration = 1
var engine_direction_z = 1 #Define engine angle where 1 = forward, -1 = backward, 0 = has no effect
var engine_direction_y = 0 #Define engine angle where 1 = up, -1 = down, 0 = has no effect

# Could be airship specific in the future, for now the same for all
var throttle_max = 100
var throttle_min = -50

var climb_input = 0
var cargo_weight = 100 #Placeholder, will be used for inertia simulation in the future
var engine_speed = 0
var target_engine_speed = 0
var relative_speed_forward = velocity.dot(transform.basis.z) #Used for calculating lift
var climb_speed = 0
var mass = 0
var throttle = 0
var left_engine_rpm = 0 #To be used in animation player
var right_engine_rpm = 0 #To be used in animation player

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_airship_specific_modifiers()

var can_switch = true #to prevent bugs from rapid switching

func _input(event):
	if event is InputEventMouseMotion:
		Ypivot.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		Xpivot.rotate_x(deg_to_rad(event.relative.y * sensitivity))
	
	if Input.is_action_pressed("throttle_up") and throttle < throttle_max:
		throttle = min(throttle + 1, throttle_max)
	
	if Input.is_action_pressed("throttle_down") and throttle > throttle_min:
		throttle = max(throttle - 1, throttle_min)
	
	climb_input = Input.get_action_strength("ascend") - Input.get_action_strength("descend")
	
	if Input.is_action_pressed("switch_airship_type") and can_switch:
		cycle_airship_type()
		can_switch = false

	if not Input.is_action_pressed("switch_airship_type"):
		can_switch = true #Reset to allow the next switching
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _process(delta):
	HUD.text = "Altitude: " + str(snapped(self.global_transform.origin.y, 1))+ "\nThrottle: " + str(throttle) + "\nMass: " + str(snapped(mass, 1))
	
	Debug.text = "Debug:" + "\nclimb_input = " + str(snapped(climb_input, 0.0001)) + "\nclimb_speed = " + str(snapped(climb_speed, 0.0001)) + "\nrelative_speed_forward = " + str(snapped(relative_speed_forward, 1)) + "\nengine_speed = " + str(snapped(engine_speed, 1))

func _physics_process(delta):
	#engine_direction and relative_speed_forward are recalculated each physics process to match position of the airship
	#This is likely bad for performance, should be rewritten in the future 
	var engine_direction = global_transform.basis.z * engine_direction_z + global_transform.basis.y * engine_direction_y
	
	target_engine_speed = throttle * engine_efficiency
	
	#engine_speed approaching target_engine_speed at 10 * delta
	if engine_speed <= target_engine_speed:
		engine_speed = min(engine_speed + 10 * delta, target_engine_speed)
	else:
		engine_speed = max(engine_speed - 10 * delta, target_engine_speed)
	
	relative_speed_forward = velocity.dot(global_transform.basis.z)
	
	#Modify climb_speed
	#The pupose of complicated expression in first if is to allow max_climb_speed in the 'middle' of operating latitudes and gradually lower climb speed near the limit of altitude and altitude = 0.
	#It is achieved using quadratic equation and min
	if climb_input > 0:
		climb_speed = min(0.01 * self.global_transform.origin.y * (max_altitude - self.global_transform.origin.y), max_climb_speed) + relative_speed_forward * lift_modifier
	if climb_input < 0:
		climb_speed = -max_climb_speed + relative_speed_forward * lift_modifier
	if climb_input == 0:
		climb_speed = 0
	
	mass = base_mass + cargo_weight
	#TODO: Include mass in velocity calculations to simulate inertia (cargo_weight should have bigger impact than base_mass for gameplay reasons)
	
	#Sum of 3 components of velocity:
	# 1. engines
	# 2. climb = lift + buyoancy
	# 3. wind force (which depends on airship direction to wind using formula sidewind_modifier * sin(wind-airship) + 1, which translates to minimum of 1 for airship parallel to the wind and sidewind_modifier + 1 for airship perpendicular to the wind) 
	velocity = (engine_direction * engine_speed
	+ Vector3.UP * climb_speed
	+ global.wind_direction * (sidewind_modifier * sin(global.wind_direction.angle_to(global_transform.basis.z)) + 1)) 
	
	#Rotation on x axis (pitch)
	var pitch_angle_diffrence = Xpivot.global_rotation.x - self.global_rotation.x
	pitch_angle_diffrence = wrapf(pitch_angle_diffrence, -PI, PI)
	var pitch = pitch_angle_diffrence * pitch_speed * delta
	
	#Rotates camera and player at the same rate in the opposite directions
	#Player rotation has airship specific limits: min_pitch_in_pitch & max_pitch_in_pitch
	#Local rotation is used for the camera (instead of global rotation) to prevent camera tilting
	self.global_rotation.x = clampf(self.global_rotation.x + pitch, min_pitch_in_pitch, max_pitch_in_pitch)
	self.global_rotation.x = wrapf(self.global_rotation.x, -PI, PI)
	Xpivot.rotation.x -= pitch
	Xpivot.rotation.x = wrapf(Xpivot.rotation.x, -PI, PI)
	
	#Rotation on y axis (yaw)
	var yaw_angle_difference = Ypivot.global_rotation.y - self.global_rotation.y
	yaw_angle_difference = wrapf(yaw_angle_difference, -PI, PI)
	var yaw = yaw_angle_difference * yaw_speed * delta
	
	#Rotates camera and player at the same rate in the opposite directions
	#Local rotation is used for the camera (instead of global rotation) to prevent camera tilting
	self.global_rotation.y += yaw
	self.global_rotation.y = wrapf(self.global_rotation.y, -PI, PI)
	
	Ypivot.rotation.y -= yaw
	Ypivot.rotation.y = wrapf(Ypivot.rotation.y, -PI, PI)
	
	#During yaw there is a small and only visual rotation on z axis (roll) to simulate aerodynamics of yaw
	visuals.rotation.z = lerp(visuals.rotation.z, -float(yaw) * max_roll_in_yaw, roll_level_speed * delta)
	
	move_and_slide()


func update_airship_specific_modifiers():
	match airship_type:
		'small':
			engine_efficiency = 0.35
			base_mass = 9000
			lift_modifier = 0.01
			yaw_speed = 0.75
			max_roll_in_yaw = 45
			roll_level_speed = 1
			max_pitch_in_pitch = 0.5
			min_pitch_in_pitch = -0.5
			pitch_speed = 1
			sidewind_modifier = 1
			max_altitude = 500
			max_climb_speed = 5
			climb_acceleration = 1
			engine_direction_z = 1
			engine_direction_y = 0
	
		'medium': #Hasn't been testes after changing flight system, needs to be tested and possibly adjusted
			engine_efficiency = 0.75
			base_mass = 20000
			lift_modifier = 0.02
			yaw_speed = 2
			max_roll_in_yaw = 45
			roll_level_speed = 1
			max_pitch_in_pitch = 0.75
			min_pitch_in_pitch = -0.5
			pitch_speed = 1
			sidewind_modifier = 2
			max_altitude = 2000
			max_climb_speed = 6
			climb_acceleration = 2
			engine_direction_z = 1
			engine_direction_y = 0
		
		'big': #Hasn't been testes after changing flight system, needs to be tested and possibly adjusted
			engine_efficiency = 1.25
			base_mass = 45000
			lift_modifier = 0.01
			yaw_speed = 0.005
			max_roll_in_yaw = 45
			roll_level_speed = 1
			max_pitch_in_pitch = 0.45
			min_pitch_in_pitch = -0.45
			pitch_speed = 1
			sidewind_modifier = 3
			max_altitude = 2500
			max_climb_speed = 8
			climb_acceleration = 0.75
			engine_direction_z = 1
			engine_direction_y = 0
		
		_:
			printerr("Airship type '", airship_type, "' not implemented in player.gd")

func cycle_airship_type():
		var current_index = AIRSHIP_TYPES.find(airship_type)
		# Calculate the next index, cycling back to 0 if past max
		var next_index = (current_index + 1) % AIRSHIP_TYPES.size()
		airship_type = AIRSHIP_TYPES[next_index]
		update_airship_specific_modifiers()
		print("Airship type switched to: ", airship_type)
