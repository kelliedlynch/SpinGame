extends Area2D
class_name Destructor

# power is a multiplier added to destruction calculations; most of the time player power is based on angular and linear velocity
var power = 1

#static func create_new(poly: Array[PackedVector2Array]) -> Destructor:
	#var n = Destructor.new()
	#n.polygons = poly
	#return n
func _ready() -> void:
	monitorable = true
	monitoring = false
