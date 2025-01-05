extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.position = $Arena.spawn_point
	var rect = [Vector2.ZERO, Vector2(60, 0), Vector2(60, 180), Vector2(0, 180)]
	$Destructible/RigidBody/Hitbox.polygon = rect
	$Destructible/VisibleObject/Polygon.polygon = rect
	$Destructible.position = Vector2(200,200)
	$Destructible/RigidBody.mass = 1000
	$Player/RigidBody.contact_monitor = true
	$Player/RigidBody.max_contacts_reported = 3
	$Player/RigidBody.body_entered.connect(ping)
	#$Player/CollisionObject.body_shape_entered.connect(ping)
	$Destructible/RigidBody.contact_monitor = true
	$Destructible/RigidBody.max_contacts_reported = 3
	#$Destructible/CollisionObject.body_entered.connect(ping)
	#$Destructible/CollisionObject.body_shape_entered.connect(ping)
	
func _physics_process(delta: float) -> void:
	var b = $Destructible/RigidBody.get_colliding_bodies()
	#if b.size() > 0:
		#print("woo", b)

func ping(node) -> void:
	print("ping", node)
