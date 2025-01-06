extends Area2D
class_name Destructor

@onready var destruct_polygon: CollisionPolygon2D = $DestructPolygon

func _ready() -> void:
	monitoring = true
	#area_entered.connect(_on_area_entered)
	#body_entered.connect(_on_body_entered)
	

func _on_area_entered(node):
	print(node)

func _on_body_entered(node):
	print("body entered")
