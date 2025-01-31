@tool
extends Destructor
class_name PlayerDestructor

var hitbox: PlayerHitbox
var max_spin_speed: float = 10
var min_spin_speed: float = .5
var spin_speed: float = 3
var spin_accel: float = .3
var spin_decel: float = .4
var spin_state = SpinState.DEFAULT

func get_power() -> float:
	var speed = spin_speed
	if hitbox.linear_velocity.length() > 500:
		speed += hitbox.linear_velocity.length() / 500
	return speed

func _on_destroyed_destructible(node):
	if target == node:
		cut_state = CutState.END_CUT
		target = null

func _try_clip_destructible(state: PhysicsDirectBodyState2D) -> bool:
	if target == null or target.boss.tangible == false:
		return false
	var destructible = target
	var power = get_power()
	#if cut_state == CutState.CUTTING or cut_state == CutState.BEGIN_CUT:
		#power += destructible.CUT_INERTIA
	var threshold = destructible.destructible_material.end_cut_threshold
	if cut_state == CutState.BEGIN_CUT:
		threshold = destructible.destructible_material.begin_cut_threshold
	if power < threshold:
		return false
	var material_limited_velocity = state.linear_velocity.limit_length(destructible.destructible_material.max_cut_speed)
	var travel = material_limited_velocity * state.step
	var next_frame_shape = get_next_frame_destructor(travel)
	var destructor_hit = destructible.apply_destructor(next_frame_shape)
	return destructor_hit
	

	
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if cut_state == CutState.BEGIN_CUT:
		target.tree_exiting.connect(_on_destroyed_destructible.bind(target))
		var clip = _try_clip_destructible(state)
		#_apply_destructible_forces(state)
		if clip == true:
			cut_state = CutState.CUTTING
		else:
			cut_state = CutState.END_CUT
	elif cut_state == CutState.CUTTING:
		var clip = _try_clip_destructible(state)
		#_apply_destructible_forces(state)
		if clip == false:
			cut_state = CutState.END_CUT
	elif cut_state == CutState.END_CUT:
		var clip = _try_clip_destructible(state)
		#_apply_destructible_forces(state)
		if clip == false:
			if target != null:
				for child in target.get_parent().get_children():
					if child == target:
						continue
					#child.remove_collision_exception_with(self)
				target.tree_exiting.disconnect(_on_destroyed_destructible)
				target = null
			cut_state = CutState.READY
		else:
			cut_state = CutState.CUTTING
	
func _physics_process(delta: float) -> void:
	if spin_state & SpinState.STOPPED:
		spin_speed = 0
	else:
		if spin_state & SpinState.ACCEL:
			spin_speed += spin_accel * delta
		if spin_state & SpinState.DECEL:
			spin_speed -= spin_decel * delta
		if spin_state & SpinState.MATERIAL_LIMITED:
			if target != null:
				spin_speed -= target.destructible_material.resistance * delta
		if spin_state & SpinState.MIN_LIMITED:
			spin_speed = clamp(spin_speed, min_spin_speed, INF)
		if spin_state & SpinState.MAX_LIMITED:
			spin_speed = clamp(spin_speed, 0, max_spin_speed)
	
enum SpinState {
	ACCEL = 1,
	DECEL = 2,
	STOPPED = 4,
	MIN_LIMITED = 8,
	MAX_LIMITED = 16,
	MATERIAL_LIMITED = 32,
	DASH_CHARGE = ACCEL + MIN_LIMITED,
	DASHING = ACCEL + MIN_LIMITED + MATERIAL_LIMITED,
	DEFAULT = ACCEL + MIN_LIMITED + MAX_LIMITED + MATERIAL_LIMITED
}
