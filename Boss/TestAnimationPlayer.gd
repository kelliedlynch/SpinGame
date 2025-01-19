extends AnimationPlayer

#func _input(_event: InputEvent) -> void:
	#if Input.is_action_just_pressed("ui_text_completion_replace"):
		#play("wave_arm")
