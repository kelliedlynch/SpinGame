extends Area2D
class_name Powerup

@onready var collision_poly: CollisionPolygon2D = $CollisionPolygon2D
@onready var visible_poly: Polygon2D = $CollisionPolygon2D/Polygon2D

var target: PlayerEntity

var duration = 0
var ticking_down = false

var flash_tween: Tween

var lifespan = -1
var in_world = false

#var prev_speed = 0

const SPIN_BOOST = 10
const MAX_SPIN_BOOST = 3
const SPIN_ACCEL_BOOST = 1.5

var call_on_collect: Callable = Callable(self, "_on_collect")
var call_on_process: Callable = Callable(self, "_on_process")

func _ready():
	monitoring = true
	monitorable = true
	collision_layer = CollisionLayer.COLLECTIBLES
	collision_mask = CollisionLayer.PLAYER_HITBOX
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_body_entered)
	in_world = true
	duration = 5
	#visible_poly.color = Color.LIME_GREEN
	var sprite_size = PolygonMath.size_of_polygon(visible_poly.polygon)
	var circle = PolygonMath.generate_circle_polygon(max(sprite_size.x, sprite_size.y) / 2)
	collision_poly.polygon = circle
	#visible_poly.polygon = circle
	flash_tween = create_tween()
	flash_tween.tween_property(visible_poly, "scale", Vector2(1.1, 1.1), .5)
	flash_tween.tween_property(visible_poly, "scale", Vector2(1, 1), .5)
	flash_tween.set_loops(200)
	#for child in visible_area.get_children():
		#if child is Polygon2D:
			#child.color = Color.LIME_GREEN
	
func _on_body_entered(node):
	if node is PlayerHitbox:
		target = node.get_parent()
		if target == Player.entity:
			_collect(node)

func _collect(_node):
	#call_on_collect.call()
	flash_tween.kill()

	for child in get_children():
		child.queue_free()
	for child in target.hitbox.get_children():
		if child is not CollisionPolygon2D: continue
		for poly in child.get_children():
			if poly is not Polygon2D: continue
			var color_before = Color(poly.color)
			var gr_mask = Color.DEEP_PINK
			gr_mask.a = .5
			var y_mask = Color.SALMON
			y_mask.a = .5
			var on_color = Color(color_before).blend(gr_mask)
			var off_color = Color(color_before).blend(y_mask)
			var tween = target.create_tween()
			var blink_interval = .25
			tween.tween_property(poly, "modulate", on_color, blink_interval)
			tween.tween_property(poly, "modulate", off_color, blink_interval)
			tween.set_loops(duration / (blink_interval * 2) - 1)
			tween.connect("finished", poly.set_modulate.bind(color_before))

		
		
	#prev_speed = target.destructor.spin_speed
	target.destructor.spin_speed += SPIN_BOOST
	target.destructor.max_spin_speed += MAX_SPIN_BOOST
	target.destructor.spin_accel *= SPIN_ACCEL_BOOST
	ticking_down = true
	
func _on_process(delta):
	if visible_poly != null:
		visible_poly.rotate(-1.7 * delta)
	if ticking_down == true:	
		duration -= delta
		if duration <= 0:
			ticking_down = false
			_on_expire()
		
func _on_expire():
	
	target.destructor.max_spin_speed -= MAX_SPIN_BOOST
	target.destructor.spin_accel /= SPIN_ACCEL_BOOST
	target.destructor.spin_speed = clamp(target.destructor.spin_speed, target.destructor.min_spin_speed, target.destructor.max_spin_speed)
	queue_free()

func _process(delta: float) -> void:
	call_on_process.call(delta)
