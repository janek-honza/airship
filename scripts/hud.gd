extends CanvasLayer

@export var controls_hidden_status = true  # Changed variable name to follow convention and set default to true

@onready var controls_cheatsheet = $Controls_cheatsheet
@onready var Ypivot = $"../YPivot"
@onready var Xpivot = $"../YPivot/XPivot"
@onready var visuals = $"../visuals"
@onready var boresight = $CenterContainer/boresight

func _input(_event):
	if Input.is_action_just_pressed("toggle_controls"):
		controls_hidden_status = not controls_hidden_status
		update_controls_visibility()

func update_controls_visibility():
	if controls_hidden_status == true:
		controls_cheatsheet.text = "[b]Show/Hide controls cheatsheet: T[/b]"
	else:
		controls_cheatsheet.text = "[b]Show/Hide controls cheatsheet: T[/b]

Inflate Ballonets (add mass): Ctrl
Deflate Ballonets (reduce mass): Space

Increase/Decrease Throttle: Scroll wheel

Pitch Up/Down: W/S
Yaw Left/Right: A/D

Free/Capture Mouse: Middle Mouse Button

Quit: Esc"

func _process(_delta):
	var screen_height = get_viewport().size.y
	var screen_width = get_viewport().size.x
	
	boresight.position.y = -Xpivot.rotation.x * screen_height / PI
	boresight.position.x = Ypivot.rotation.y * screen_width / PI
	
	boresight.rotation = visuals.rotation.z
