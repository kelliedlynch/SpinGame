extends Area2D
class_name Destructor

# power is a multiplier added to destruction calculations; most of the time player power is based on angular and linear velocity
var power = 1

@onready var parent = get_parent()

# { next_frame: current_frame }
# if current has key, shape is a next frame prediction
var current = {}
# { current_frame: next_frame }
# if next has key, shape is the actual destructor
var next = {}
var predictions = {}

#static func create_new(poly: Array[PackedVector2Array]) -> Destructor:
	#var n = Destructor.new()
	#n.polygons = poly
	#return n
func _ready() -> void:
	monitorable = true
	monitoring = false
	child_entered_tree.connect(_on_child_added)
	child_exiting_tree.connect(_on_child_removed)
	#collision_mask = 1 & 10

func _on_child_added(node: Node2D):
	if node is CollisionPolygon2D and !current.has(node):
		var next_frame = node.duplicate()
		next[node] = next_frame
		current[next_frame] = node
		add_child(next_frame)

func _on_child_removed(node: Node2D):
	if node is CollisionPolygon2D and !current.has(node):
		var next_frame = next[node]
		next.erase(node)
		current.erase(next_frame)
		#remove_child(next_frame)
		next_frame.queue_free()

func _on_destroyed_material(d: Destructor, mat: DestructibleEntity):
	await get_tree().physics_frame
	parent.linear_velocity -= parent.linear_velocity * Vector2(mat.material_resistance, mat.material_resistance)
	parent.get_parent().spin_speed -= mat.material_resistance

func _physics_process(delta: float) -> void:
	var spin = parent.get_parent().spin_speed
	var next_frame_transform = parent.linear_velocity / 8 * delta * spin
	var next_frame_scale = delta * spin / 10
	#print(delta, spin, next_frame_scale)
	#print(parent.get_parent().scale)
	
	if next_frame_transform == Vector2.ZERO: return
	for current_frame_shape in next:
		var next_frame_shape = next[current_frame_shape]
		next_frame_shape.position = current_frame_shape.position + next_frame_transform
		next_frame_shape.scale = current_frame_shape.scale + Vector2(next_frame_scale, next_frame_scale)
