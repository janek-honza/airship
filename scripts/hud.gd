extends CanvasLayer

@export var controls_hidden_status = false  # Changed variable name to follow convention and set default to true
@onready var controls_shown = $ControlsShown
@onready var controls_hidden = $ControlsHidden

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_controls_visibility()

func _input(event):
	if Input.is_action_just_pressed("toggle_controls"):
		controls_hidden_status = not controls_hidden_status  # Toggle the state
		update_controls_visibility()
	
	if Input.is_action_just_pressed("toggle_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func update_controls_visibility():
	# Show/hide controls based on state
	controls_shown.visible = not controls_hidden_status
	controls_hidden.visible = controls_hidden_status
