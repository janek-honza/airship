extends Node3D

@export var player_path: String = "../Player"
@export var spawn_radius: float = 100.0
@export var wind_direction: Vector3 = Vector3(1, 0, -1)
@export var wind_speed: float = 15.0
@export var trail_lifetime: float = 1.5
@export var spawn_interval: float = 0.2
@export var max_trails: int = 20

var player: Node3D
var trail_scene: PackedScene
var active_trails: Array[Node3D] = []
var time_since_spawn: float = 0.0

class WindTrail extends MeshInstance3D:
	var direction: Vector3
	var speed: float
	var lifetime: float = 0.0
	var length: float = 100.0
	
	func _process(delta: float):
		lifetime += delta
		
		# Update position
		position += direction * speed * delta
		
		# Update mesh
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		
		var trail_width = 1 * (1.0 - lifetime / 2.0)  # Trail gets thinner over time
		var alpha = 1.0 - (lifetime / 2.0)  # Trail fades out
		alpha = max(0, alpha)  # Prevent negative alpha
		
		# Create trail geometry
		var up = Vector3.UP
		var right = direction.cross(up).normalized() * trail_width
		
		var color = Color(1, 1, 1, alpha)
		
		# Start point
		mesh.surface_set_color(color)
		mesh.surface_add_vertex(Vector3.ZERO + right)
		mesh.surface_set_color(color)
		mesh.surface_add_vertex(Vector3.ZERO - right)
		
		# End point
		mesh.surface_set_color(Color(1, 1, 1, 0))  # Fade to transparent
		mesh.surface_add_vertex(-direction * length + right)
		mesh.surface_set_color(Color(1, 1, 1, 0))
		mesh.surface_add_vertex(-direction * length - right)
		
		mesh.surface_end()

func _ready():
	player = get_node_or_null(player_path)
	setup_trail_scene()

func setup_trail_scene():
	# Create the wind trail mesh resource
	var mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.unshaded = true  # Make the trails unaffected by lighting
	material.albedo_color = Color(1, 1, 1, 0.5)
	material.emission_enabled = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.emission = Color(1, 1, 1, 0.2)
	material.render_priority = 1
	
	# Create the trail node
	var trail_node = WindTrail.new()
	trail_node.mesh = mesh
	trail_node.material_override = material
	
	# Pack the scene
	trail_scene = PackedScene.new()
	var result = trail_scene.pack(trail_node)
	if result != OK:
		push_warning("Failed to pack trail scene")

func _process(delta: float):
	if not player:
		return
		
	time_since_spawn += delta
	
	# Spawn new trails periodically
	if time_since_spawn >= spawn_interval:
		spawn_trail()
		time_since_spawn = 0.0
	
	# Update and clean up existing trails
	var i = active_trails.size() - 1
	while i >= 0:
		var trail = active_trails[i] as WindTrail
		if trail and trail.lifetime > trail_lifetime:
			active_trails.remove_at(i)
			trail.queue_free()
		i -= 1

func spawn_trail():
	if active_trails.size() >= max_trails:
		return
	
	# Random position around player
	var random_angle = randf() * TAU
	var random_radius = randf_range(2.0, spawn_radius)
	var spawn_pos = player.global_position + Vector3(
		cos(random_angle) * random_radius,
		randf_range(0.5, 2.5),  # Random height
		sin(random_angle) * random_radius
	)
	
	# Instantiate trail
	var trail = trail_scene.instantiate() as WindTrail
	if trail:
		add_child(trail)
		trail.global_position = spawn_pos
		trail.direction = wind_direction.normalized()
		trail.speed = wind_speed
		trail.lifetime = 0.0
		
		active_trails.append(trail)
