extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.position = $Arena.spawn_point
	var w = 160
	var h = 280
	var rect = [Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)]
	$Destructible.body.load_polygons(rect)
	$Destructible.body.position = Vector2(200,200)
	$Destructible.body.mass = 10000

	
#func _physics_process(delta: float) -> void:
	#var b = $Destructible/RigidBody.get_colliding_bodies()
	##if b.size() > 0:
		##print("woo", b)

func ping(node) -> void:
	print("ping", node)
