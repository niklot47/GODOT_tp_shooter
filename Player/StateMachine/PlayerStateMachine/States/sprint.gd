extends Motion

signal sprint_started
signal sprint_ended

func _enter() -> void:
	print(name)
	sprint_started.emit()

func _state_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit("SprintJump")
	
	if event.is_action_released("sprint") and sprint_remaning > PLAYER_MOVEMENT_STATS.sprint_minimum_threshhold:
		sprint_ended.emit()
		finished.emit("Run")

func _update(delta: float) -> void:
	set_direction()
	calculate_velocity(sprint_speed, direction, PLAYER_MOVEMENT_STATS.acceleraion, delta)
	
	sprint_remaning -= delta
	
	if sprint_remaning <= 0.0:
		sprint_ended.emit()
		finished.emit("Run")
	
	if direction == Vector3.ZERO:
		sprint_ended.emit()
		finished.emit("Idle")
