@tool
@abstract
extends Node3D
class_name Usable

const TIME_MARKER_ANIMATION_MAIN = &"use"

enum TimeMarker {
	LOOP_START,
	DO_USAGE,
	LOOP_BACK,
	UNLOCK,
}

const INACTIVE_STATE: int = -1

@export var usable_info: UsableInfo:
	set(v):
		usable_info = v
		update_configuration_warnings()

# @export var _time_markers: AnimationPlayer
@export var _primary_animation_tree: AnimationTree

@export_group("Animations", "_anim_name_")
@export var _anim_name_draw: StringName = &""
@export var _anim_name_use: StringName = &""
@export var _anim_name_release: StringName = &""
@export var _anim_name_idle: StringName = &""
@export var _anim_name_walk: StringName = &""
@export var _anim_name_run: StringName = &""
@export var _anim_name_midair: StringName = &""

@export_group("Obsolete","")
@export var _animation_player: AnimationPlayer
@export var _use_animation: StringName = &""

var state: int:
	get: return _state

var _anim_state_machine: AnimationNodeStateMachinePlayback
var _state = INACTIVE_STATE

var _locked: bool = false:
	set(v):
		_locked = v
		if v:
			locked.emit()
		else:
			unlocked.emit()

var _loop_start: float = 0.0

signal used(mode: int)
signal released()
signal locked()
signal unlocked()

func _ready() -> void:
	if !Engine.is_editor_hint():
		assert(usable_info)

## Called upon drawing the weapon out of the player
##  (NOT DRAWING ONTO THE SCREEN!!!)
func draw() -> void:
	#_animation_player.play(_anim_name_draw)
	#_animation_player.seek(0.0)
	_anim_state_machine = _primary_animation_tree["parameters/playback"]
	_anim_state_machine.start(&"Start")
	_locked = false

func use(mode: int) -> void:
	if !Engine.is_editor_hint():
		if !is_locked() && mode > INACTIVE_STATE && !is_in_use():
			_state = mode
			_locked = true
			used.emit(mode)
			_anim_state_machine.start(_anim_name_use)
			#_animation_player.play(_anim_name_use)
			#_animation_player.seek(0.0)

func release() -> void:
	if !Engine.is_editor_hint():
		if is_in_use():
			_state = INACTIVE_STATE
			if !_anim_name_release.is_empty():
				_anim_state_machine.start(_anim_name_release)
			released.emit()

## To be overridden
func anim_use() -> void:
	pass

func anim_loop_back() -> void:
	if Engine.is_editor_hint(): return
	if _state != INACTIVE_STATE:
		#_animation_player.seek(_loop_start)
		# _time_markers.seek(_loop_start, false)
		pass

func anim_start_loop() -> void:
	if Engine.is_editor_hint(): return
	# _loop_start = _time_markers.current_animation_position

func anim_unlock() -> void:
	if Engine.is_editor_hint(): return
	_locked = false


func is_locked() -> bool:

	return _locked

func is_in_use() -> bool:
	return _state > INACTIVE_STATE


func _get_configuration_warnings() -> PackedStringArray:
	if !usable_info:
		return ["No usable info provided!"]
	return []
