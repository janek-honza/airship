extends Node3D
var rings : Array = []
var current_ring_index : int = 0
signal player_flew_through_ring

# Stopwatch variables
var stopwatch_running : bool = false
var start_time : float = 0.0
var current_time : float = 0.0
var lap_time : float = 0.0
var stopwatch_label : Label

func _ready():
	rings = get_children().filter(func(node): return node.name.begins_with("ring"))
	update_ring_visibility()
	
	for ring in rings:
		var area = ring.get_node("Area3D")
		if area:
			area.player_flew_through_ring.connect(_on_player_flew_through_ring)
	
	# Create a stopwatch label
	setup_stopwatch_ui()

func update_ring_visibility():
	for i in range(rings.size()):
		rings[i].visible = (i == current_ring_index)

func _on_player_flew_through_ring():
	current_ring_index = (current_ring_index + 1) % rings.size()
	
	# Stopwatch logic when reaching ring 1
	if current_ring_index == 1:
		handle_ring2_timing()
	
	update_ring_visibility()

# Stopwatch setup function
func setup_stopwatch_ui():
	stopwatch_label = Label.new()
	stopwatch_label.text = "00:00.000"
	stopwatch_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(stopwatch_label)
	add_child(canvas_layer)
	
	# Position the label at the top of the screen
	stopwatch_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	stopwatch_label.offset_top = 20

# Function to handle timing for ring 2
func handle_ring2_timing():
	if not stopwatch_running:
		# Start the stopwatch
		start_time = Time.get_ticks_msec()
		current_time = 0.0
		stopwatch_running = true
		stopwatch_label.text = "00:00.000"
	else:
		# Stop the stopwatch and record the lap time
		lap_time = (Time.get_ticks_msec() - start_time) / 1000.0
		stopwatch_running = false
		
		# Format and display the lap time
		var minutes = int(lap_time / 60)
		var seconds = int(lap_time) % 60
		var milliseconds = int((lap_time - int(lap_time)) * 1000)
		stopwatch_label.text = "%02d:%02d.%03d" % [minutes, seconds, milliseconds]

# Process function to update the stopwatch display
func _process(delta):
	if stopwatch_running:
		current_time = (Time.get_ticks_msec() - start_time) / 1000.0
		
		# Format and display the current time
		var minutes = int(current_time / 60)
		var seconds = int(current_time) % 60
		var milliseconds = int((current_time - int(current_time)) * 1000)
		stopwatch_label.text = "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
