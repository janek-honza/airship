extends CanvasLayer

@export var controls_hidden_status = false  # Changed variable name to follow convention and set default to true
@onready var controls_cheatsheet = $Controls_cheatsheet

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_controls_visibility()

func _input(event):
	if Input.is_action_just_pressed("toggle_controls"):
		controls_hidden_status = not controls_hidden_status
		update_controls_visibility()
	
	if Input.is_action_just_pressed("toggle_mouse"): #This is not an correct/clean way to do it, but Input.MOUSE_MODE is weird and other aproaches don't work
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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

Free/Capture Mouse: Esc"
