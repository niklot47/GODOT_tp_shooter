extends Node3D

@export_category("Camera script variables")
@export_group("Camera position & alignment")
@export var character: CharacterBody3D
@export var edge_spring_arm: SpringArm3D
@export var rear_spring_arm: SpringArm3D
@export var camera: Camera3D
@export var camera_alignment_speed: float = 0.2
@export var mouse_sensativity: float = 0.001
@export var max_y_rotation: float = 1.2

@export_group("AIM")
@export var aim_rear_spring_length: float = 0.5
@export var aim_edge_spring_length: float = 0.5
@export var aim_speed: float = 0.2
@export var aim_fov: float = 55

@export_group("Sprint camera")
@export var sprint_rear_spring_length: float = 0.5
@export var sprint_edge_spring_length: float = 0.5
@export var sprint_camera_speed: float = 0.8
@export var sprint_fov: float = 90

var camera_rotation: Vector2 = Vector2.ZERO
var camera_tween: Tween
enum CameraAliignment { LEFT = -1, CENTER = 0, RIGHT = 1 }
var current_camera_alignment: int = CameraAliignment.RIGHT

@onready var defalt_edge_spring_arm_length: float = edge_spring_arm.spring_length
@onready var defalt_rear_spring_arm_length: float = rear_spring_arm.spring_length
@onready var defalt_fov: float = camera.fov

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event is InputEventMouseMotion:
		var mouse_event: Vector2 = event.screen_relative * mouse_sensativity
		camera_look(mouse_event)
		
	if event.is_action_pressed("swap_camera_alignment"):
		swap_camera_alignment()
		
	if event.is_action_pressed("aim"):
		enter_aim()
		
	if event.is_action_released("aim"):
		exit_aim()		
		
	if event.is_action_pressed("sprint"):
		enter_sprint()
		
	if event.is_action_released("sprint"):
		exit_sprint()
	
func camera_look(mouse_movement: Vector2) -> void:
	camera_rotation += mouse_movement
	transform.basis = Basis()
	character.transform.basis = Basis()
	character.rotate_object_local(Vector3(0, 1, 0), -camera_rotation.x)
	rotate_object_local(Vector3(1, 0, 0), -camera_rotation.y)
	camera_rotation.y = clamp(camera_rotation.y, -max_y_rotation, max_y_rotation)
	
func swap_camera_alignment() -> void:
	match current_camera_alignment:
		CameraAliignment.RIGHT:
			set_current_camera_aligment(CameraAliignment.LEFT)
		CameraAliignment.LEFT:
			set_current_camera_aligment(CameraAliignment.RIGHT)
		CameraAliignment.CENTER:
			return
			
	var new_pos = defalt_edge_spring_arm_length * current_camera_alignment
	set_rear_spring_arm_position(new_pos, camera_alignment_speed)
	
func set_current_camera_aligment(alignment: CameraAliignment) -> void:
	current_camera_alignment = alignment
	
func set_rear_spring_arm_position(pos: float, speed: float) -> void:
	set_camera_tween([
		{ "node": edge_spring_arm, "property": "spring_length", "value": pos, "duration": speed }
	], false, false)

func enter_aim() -> void:
	set_camera_tween([
		{ "node": camera, "property": "fov", "value": aim_fov, "duration": aim_speed },
		{ "node": edge_spring_arm, "property": "spring_length", "value": aim_edge_spring_length * current_camera_alignment, "duration": aim_speed },
		{ "node": rear_spring_arm, "property": "spring_length", "value": aim_rear_spring_length, "duration": aim_speed }
	])

func exit_aim() -> void:
	set_camera_tween([
		{ "node": camera, "property": "fov", "value": defalt_fov, "duration": aim_speed },
		{ "node": edge_spring_arm, "property": "spring_length", "value": defalt_edge_spring_arm_length * current_camera_alignment, "duration": aim_speed },
		{ "node": rear_spring_arm, "property": "spring_length", "value": defalt_rear_spring_arm_length, "duration": aim_speed }
	])

func enter_sprint() -> void:
	set_camera_tween([
		{ "node": camera, "property": "fov", "value": sprint_fov, "duration": sprint_camera_speed },
		{ "node": edge_spring_arm, "property": "spring_length", "value": defalt_edge_spring_arm_length * current_camera_alignment, "duration": sprint_camera_speed },
		{ "node": rear_spring_arm, "property": "spring_length", "value": defalt_rear_spring_arm_length, "duration": sprint_camera_speed }
	])

func exit_sprint() -> void:
	set_camera_tween([
		{ "node": camera, "property": "fov", "value": defalt_fov, "duration": sprint_camera_speed },
		{ "node": edge_spring_arm, "property": "spring_length", "value": defalt_edge_spring_arm_length * current_camera_alignment, "duration": aim_speed },
		{ "node": rear_spring_arm, "property": "spring_length", "value": defalt_rear_spring_arm_length, "duration": aim_speed }
	])
	
func set_camera_tween(tween_targets: Array = [], paralel: bool = true, do_ease: bool = true, ease_type: Tween.EaseType = Tween.EASE_IN_OUT)-> void:
	if camera_tween:
		camera_tween.kill()
	
	camera_tween = get_tree().create_tween()
	if paralel:
		camera_tween.set_parallel()
	
	if do_ease:
		camera_tween.set_trans(Tween.TRANS_EXPO)
		camera_tween.set_ease(ease_type)
	
	for tween in tween_targets:
		camera_tween.tween_property(
			tween.node,
			tween.property,
			tween.value,
			tween.duration
		)
