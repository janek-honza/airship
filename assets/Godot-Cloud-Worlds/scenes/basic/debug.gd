extends Label

func _process(_delta):
	var debug_string : String = "FPS = " + str(Engine.get_frames_per_second()) + "\n"
	set_text(debug_string)
