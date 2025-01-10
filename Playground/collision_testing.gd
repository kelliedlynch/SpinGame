extends Node2D

var queued = null
var countdown = 10

func _ready() -> void:
	$Square.area_entered.connect(_on_square_entered)
	$Square.area_exited.connect(_on_square_exited)

func redraw():
	var coll = $Square.get_children()[0]
	var poly = coll.polygon
	#$Square.remove_child(coll)
	var new_poly = CollisionPolygon2D.new()
	new_poly.polygon = poly
	$Square.add_child(new_poly)
	queued = coll
	#$Square.call_deferred("remove_child", coll)

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		redraw()
		
func _on_square_entered(node):
	print("square entered")

func _on_square_exited(node):
	print("square exited")

func _process(delta):
	if queued == null: return
	if countdown <= 0:
		var children = $Square.get_children()
		$Square.call_deferred("remove_child", queued)
		queued = null
		countdown = 10
	countdown -= 1
