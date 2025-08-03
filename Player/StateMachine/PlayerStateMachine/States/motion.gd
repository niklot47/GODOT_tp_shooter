extends State
class_name Motion

signal velocity_update(vel: Vector3)

var speed: float
var sprint_speed: float
var aim_speed: float
var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

static var input_dir: Vector2 = Vector2.ZERO
static var direction: Vector3 = Vector3.ZERO
static var velocity: Vector3 = Vector3.ZERO
static var sprint_remaning: float = 0

const PLAYER_MOVEMENT_STATS = preload("res://Player/player_movement_stats.tres")

func _ready() -> void:
	sprint_remaning = PLAYER_MOVEMENT_STATS.sprint_duration
	velocity_update.connect(owner.set_velocity_from_motion)
	speed = PLAYER_MOVEMENT_STATS.get_velocity(PLAYER_MOVEMENT_STATS.jump_distance, PLAYER_MOVEMENT_STATS.time_to_jump_apex)
	sprint_speed = PLAYER_MOVEMENT_STATS.get_velocity(PLAYER_MOVEMENT_STATS.sprint_jump_distance, PLAYER_MOVEMENT_STATS.time_to_jump_apex)
	aim_speed = PLAYER_MOVEMENT_STATS.get_velocity(PLAYER_MOVEMENT_STATS.aim_jump_distance, PLAYER_MOVEMENT_STATS.time_to_jump_apex)
	jump_gravity = PLAYER_MOVEMENT_STATS.get_jump_gravity()
	fall_gravity = PLAYER_MOVEMENT_STATS.get_jump_gravity()
	jump_velocity = PLAYER_MOVEMENT_STATS.get_jump_velocity(jump_gravity)

func set_direction() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (owner.global_transform.basis *Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
func calculate_velocity(_speed: float, _direction: Vector3, acceleration: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, _direction.x*_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, _direction.z*_speed, acceleration * delta)
	velocity_update.emit(velocity)
	
func calculate_gravity(delta: float) -> void:
	if not owner.is_on_floor():
		if velocity.y > 0:
			velocity.y -= jump_gravity * delta
		else:
			velocity.y -= fall_gravity * delta
	
func is_on_floor() -> bool:
	return owner.is_on_floor()
	
func replenish_sprint(delta: float, multiple: float = 1) -> void:
	sprint_remaning = min(sprint_remaning + delta * multiple, PLAYER_MOVEMENT_STATS.sprint_duration)
