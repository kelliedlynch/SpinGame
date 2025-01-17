extends SGEntityBase
class_name Powerup

@onready var hitbox: Area2D = $Hitbox
@onready var visible_area: VisibleArea = $VisibleArea

var target: Player

var duration = 0
var ticking_down = false

var lifespan = -1
var in_world = false

var prev_speed = 0

var call_on_collect: Callable = Callable(self, "_on_collect")
var call_on_process: Callable = Callable(self, "_on_process")

func _ready():
	hitbox.monitoring = true
	hitbox.monitorable = true
	hitbox.collision_layer = 2
	hitbox.collision_mask = 5
	hitbox.body_entered.connect(_on_body_entered)
	hitbox.area_entered.connect(_on_body_entered)
	in_world = true
	duration = 5
	color = Color.LIME_GREEN
	update_all_polygons([PolygonMath.generate_circle_polygon(12)])
	var tween = create_tween()
	tween.tween_property(visible_area, "scale", Vector2(1.5, 1.5), .5)
	tween.tween_property(visible_area, "scale", Vector2(1, 1), .5)
	tween.set_loops(200)
	#for child in visible_area.get_children():
		#if child is Polygon2D:
			#child.color = Color.LIME_GREEN
	
func _on_body_entered(node):
	if node is PlayerHitbox:
		target = node.get_parent()
		_collect(node)
		pass

func _collect(_node):
	call_on_collect.call()
	for child in get_children():
		child.queue_free()
	
func _on_collect():
	for child in target.visible_area.get_children():
		var color_before = Color(child.color)
		var mask = Color(color)
		mask.a = .5
		var to_color = Color(color_before).blend(mask)
		var tween = create_tween()
		var blink_interval = .25
		tween.tween_property(child, "modulate", to_color, blink_interval)
		tween.tween_property(child, "modulate", color, blink_interval)
		tween.set_loops(duration / (blink_interval * 2) - 1)
		tween.connect("finished", child.set_modulate.bind(color_before))
		#tween.tween_property(child, "modulate", color_before, 0)
		
		
	prev_speed = target.destructor.spin_speed
	target.destructor.spin_speed += 10
	target.destructor.max_spin_speed += 2
	target.destructor.spin_accel += 3
	ticking_down = true
	
func _on_process(delta):
	if ticking_down == true:	
		duration -= delta
		if duration <= 0:
			ticking_down = false
			_on_expire()
		
func _on_expire():
	target.destructor.spin_speed = prev_speed
	target.destructor.max_spin_speed -= 2
	target.destructor.spin_accel -= 3
	queue_free()

func _process(delta: float) -> void:
	call_on_process.call(delta)
