extends Node2D

var forces = {}
var frame = 0
var total_frame_time = 0

func _ready() -> void:
	#var arenashape = ConcavePolygonShape2D.new()
	var ss = get_viewport_rect()

	var w = 10
	var tw = RectangleShape2D.new()
	tw.size = Vector2(ss.size.x, w)
	var bw = RectangleShape2D.new()
	bw.size = tw.size
	var lw = RectangleShape2D.new()
	lw.size = Vector2(w, ss.size.y)
	var rw = RectangleShape2D.new()
	rw.size = lw.size
	var tws = CollisionShape2D.new()
	tws.shape = tw
	tws.position = Vector2.ZERO
	tws.position += tw.size / 2
	var bws = CollisionShape2D.new()
	bws.shape = bw
	bws.position = Vector2(0, ss.size.y - w)
	bws.position += bw.size / 2
	var lws = CollisionShape2D.new()
	lws.shape = lw
	lws.position = Vector2.ZERO
	lws.position += lw.size / 2
	var rws = CollisionShape2D.new()
	rws.shape = rw
	rws.position = Vector2(ss.size.x - w, 0)
	rws.position += rw.size / 2
	var arena = $Arena
	
	arena.add_child(tws)
	arena.add_child(bws)
	arena.add_child(lws)
	arena.add_child(rws)
	#add_child(arena)
	
	
	for i in 1000:
		var b = RigidBody2D.new()
		var s = CollisionShape2D.new()
		#var p = RectangleShape2D.new()
		#s.shape = p
		var size = 20
		#var p = ConcavePolygonShape2D.new()
		#p.segments = [Vector2(0,0), Vector2(size, 0),\
		#Vector2(size, 0), Vector2(size, size),\
		#Vector2(size, size), Vector2(0, size),\
		#Vector2(0, size), Vector2(0, 0)]
		var p = ConvexPolygonShape2D.new()
		p.points = [Vector2(0,0), Vector2(size, 0), Vector2(size, size), Vector2(0, size)]
		s.add_child(p)
		#var s = CollisionPolygon2D.new()
		#s.polygon = [Vector2(0,0), Vector2(size, 0), Vector2(size, size), Vector2(0, size)]
		b.add_child(s)
		var px = randi_range(2 * w, int(ss.size.x) - 2 * w)
		var py = randi_range(2 * w, int(ss.size.y) - 2 * w)
		b.position = Vector2(px, py)
		add_child(b)
		var angle = randi_range(0, 360)
		var rad = deg_to_rad(angle)
		var vec = Vector2.from_angle(rad)
		vec *= Vector2(10000, 10000)
		forces[b] = vec
		
func _process(delta: float) -> void:
	if frame == 100:
		print("100 frames time ", total_frame_time)
		frame = 0
		total_frame_time = 0
	else:
		frame +=1
		total_frame_time += delta

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		for key in forces:
			key.apply_central_force(forces[key])
