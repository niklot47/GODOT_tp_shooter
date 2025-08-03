extends Motion

func _enter() -> void:
	print(name)

func _state_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit("Jump")
		
	if event.is_action_pressed("sprint") and sprint_remaning > PLAYER_MOVEMENT_STATS.sprint_minimum_threshhold:
		finished.emit("Sprint")

	if event.is_action_pressed("aim"):
		finished.emit("AimWalk")
		
		
func _update(delta: float) -> void:
	set_direction()
	calculate_velocity(speed, direction, PLAYER_MOVEMENT_STATS.acceleraion, delta)
	replenish_sprint(delta, 0.5)
	
	if direction == Vector3.ZERO:
		finished.emit("Idle")

	if not is_on_floor():
		finished.emit("fall")
