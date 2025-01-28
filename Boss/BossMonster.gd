extends Node2D
class_name BossMonster

var boss_name = "Boss Name"
@onready var controller: BossController = $BossController
@onready var destructibles: Node2D = $Destructibles
@onready var heart: BossHeart = $Heart
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var arena: Arena

@export var heart_location: DestructibleHitbox

var _tangible: bool = true
var tangible: bool:
	get: return _tangible
	set(value):
		change_tangible_state.emit(value)
		_tangible = value
signal change_tangible_state

func _ready() -> void:
	z_index = RenderLayer.ARENA_ENTITIES
	$shadow.z_index = RenderLayer.ENTITY_SHADOWS
	$shadow.z_as_relative = false
	#controller.animation_player = $AnimationPlayer
	change_tangible_state.connect(_on_change_tangible_state)
	for child in destructibles.get_children():
		child.boss = self
		child.shape_destroyed.connect(_on_shape_destroyed)
	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2

func _on_shape_destroyed(node):
	if node == heart_location:
		heart.revealed = true
	if destructibles.get_child_count() == 0:
		queue_free()

func calculate_size() -> Vector2:
	var min_x = 1000000
	var max_x = 0
	var min_y = 1000000
	var max_y = 0
	for child in destructibles.get_children():
		for poly in child.get_children():
			if poly is CollisionPolygon2D:
				for vertex in poly.polygon:
					var v = poly.to_global(vertex)
					if v.x < min_x: min_x = v.x
					if v.y < min_y: min_y = v.y
					if v.x > min_x: max_x = v.x
					if v.y > min_y: max_y = v.y
	return Vector2(max_x - min_x, max_y - min_y)

#func move_to_position(pos: Vector2):
	#for hitbox in destructibles.get_children():
		#for coll in hitbox.get_children():
			#if coll is CollisionPolygon2D:
				#coll.position = pos

func _on_change_tangible_state(val: bool) -> void:
	var layer = CollisionLayer.ENEMY_HITBOX if val else CollisionLayer.INTANGIBLE_ENEMY
	for child: DestructibleHitbox in destructibles.get_children():
		child.collision_layer = layer
	if controller.boss.heart.revealed == true:
		heart.collision_layer = layer
			
