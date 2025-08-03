extends Motion

func _enter() -> void:
	print(name)

func _update(delta: float) -> void:
	calculate_gravity(delta)
	calculate_velocity(speed, direction, PLAYER_MOVEMENT_STATS.in_air_acceleration, delta)
	
	if is_on_floor():
		set_direction()
		if Input.is_action_pressed("sprint") and sprint_remaning > PLAYER_MOVEMENT_STATS.sprint_minimum_threshhold:
			finished.emit("Sprint")
		elif direction != Vector3.ZERO:
			finished.emit("Run")
		else:
			finished.emit("Idle")
