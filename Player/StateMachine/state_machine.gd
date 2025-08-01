extends Node
class_name StateMachine

@export var start_state: State

var state_map: Dictionary
var current_state: State = null
var _active: bool = false
