extends CharacterBody3D
class_name Player

enum Trigger {
	NONE,
	WALKED,
	JUMPED,
	FELL,
	LANDED,
	STOPPED,
	GRABBED_LEDGE,
	DASHED,
	STARTED_WALLRUN,
	STARTED_CROUCH,
	ENDED_CROUCH,
	BATJUMPED,
}

enum WeaponIndex {
	PISTOL          = 0,
	SHOTGUN         = 1,
	ROCKETLAUNCHER  = 2,
	CROSSBOW        = 3,
	TELEGUN         = 4,
}

@export var voxel_terrain : VoxelTerrain
@export var world : Node3D

@onready var movement_input: InputVector = %MovementInputVector
@onready var look_input: InputVector = %MouseLookInputVector
@onready var move_component: MovementComponent3D = %QuakeMovementComponent3D
@onready var swivel: Swivel = %Swivel
@onready var state_machine: StateMachine = %StateMachine
@onready var visual_component : Node3D = %VisualComponent
@onready var raycast_head: RayCast3D = %BodyRaycasts/Head
@onready var raycast_feet: RayCast3D = %BodyRaycasts/Feet
@onready var raycast_body_l: RayCast3D = %BodyRaycasts/BodyLeft
@onready var raycast_body_m: RayCast3D = %BodyRaycasts/BodyMid
@onready var raycast_body_r: RayCast3D = %BodyRaycasts/BodyRight
@onready var marker_3d: Marker3D = $Swivel/Camera3D/Marker3D
@onready var voxel_tool : VoxelTool = voxel_terrain.get_voxel_tool()
@onready var ray_cast_3d: RayCast3D = $Swivel/Camera3D/RayCast3D
@onready var camera_3d: Camera3D = $Swivel/Camera3D

var grabbed_body : RigidBody3D = null
const THROW_FORCE : float = 18.0

var _facing_tween: Tween
var facing_direction: Vector2:
	get: return swivel.direction
	set(v): swivel.direction = v

var current_state: StringName:
	get: return state_machine.current_state.name

@onready var _jumps: int = _max_jumps
var _max_jumps : int = 2

@onready var _dashes: int = _max_dashes
var _dash_timer: SceneTreeTimer
var _dash_recover_timer: SceneTreeTimer
var _dash_direction: Vector3
var _max_dashes: int = 3:
	set(v):
		_max_dashes = v
		_dashes = v

var _batjump_timer: SceneTreeTimer

var _walls_on_sides: bool = false
var _wall_facing_normal: Vector3
var _wallrun_direction: Vector3
var _has_wallrun: bool = true


const SCENE_PATH_PISTOL = "uid://bjjhkb86mk45j"
const SCENE_PATH_SHOTGUN = "uid://cfr1hc65nmkqs"
const SCENE_PATH_ROCKET_LAUNCHER = "uid://c8dodjemgjswr"
const TERRAIN_UNIT = preload("uid://d062onkv4du5i")
func _enter_tree() -> void:
	if is_node_ready(): return
	
	# Pull values from the current save
	#if !ConfigPlayerSave.allow_max:
		#_max_jumps = ConfigPlayerSave.max_jumps
		#_max_dashes = ConfigPlayerSave.max_dashes
		#_has_wallrun = ConfigPlayerSave.has_wallrun

	# Load necessary usables
	#if ConfigPlayerSave.has_pistol || ConfigPlayerSave.allow_all_weapons:
		#%UsableManager.set_usable(load(SCENE_PATH_PISTOL).instantiate(), WeaponIndex.PISTOL)
	#if ConfigPlayerSave.has_shotgun || ConfigPlayerSave.allow_all_weapons:
		#%UsableManager.set_usable(load(SCENE_PATH_SHOTGUN).instantiate(), WeaponIndex.SHOTGUN)
	#if ConfigPlayerSave.has_rocketlauncher || ConfigPlayerSave.allow_all_weapons:
		#%UsableManager.set_usable(load(SCENE_PATH_ROCKET_LAUNCHER).instantiate(), WeaponIndex.ROCKETLAUNCHER)

func _process(delta: float) -> void:
	# Set the swivel camera stuff
	#if (!_facing_tween || !_facing_tween.is_running()) && !look_input.xy.is_zero_approx() && (look_input is not MouseVelocityInputVector || look_input.mouse_captured):
	#DebugHUD.AppendLine("LookInput: %s" % look_input.xy)
	swivel.directional_velocity = look_input.xy
	
	# Orient the world model
	if !state_machine.current_state.vfx_world_model_lock_orientation:
		var r = lerp_angle(visual_component.rotation.y, facing_direction.x, 10.0 * delta)
		visual_component.rotation.y = r
	
	# Orient the minimap
	%ClientHUD.minimap_view_orientation = %Swivel/Camera3D.global_basis

	# DebugHUD stuff
	#DebugHUD.AppendLine("Player ==================================")
	#DebugHUD.AppendLine("Position: %10.3v" % global_position)
	#DebugHUD.AppendLine("Velocity: %10.3v" % velocity)
	#DebugHUD.AppendLine("Speed: %10.3f m/s" % Vector2(velocity.x, velocity.z).length())
	#DebugHUD.AppendLine("Facing: %10.3v" % facing_direction)
	#DebugHUD.AppendLine("Input Direction: %10.3v" % move_component.input_direction)
	#DebugHUD.AppendLine("Wish Direction: %10.3v" % move_component.wish_direction)
	#DebugHUD.AppendLine("Dash Direction: %10.3v" % _dash_direction)
	#DebugHUD.AppendLine("Jumps: %s/%s" % [_jumps, _max_jumps])
	#DebugHUD.AppendLine("Dashes: %s/%s : %.3f" % [_dashes, _max_dashes, 1.0 - (_dash_recover_timer.time_left if _dash_recover_timer else 0.0) / DASH_RECOVERY_TIME])
	#DebugHUD.AppendLine("Current state: %s" % state_machine.state_name)

	var dir = Vector3(velocity.x, 0, velocity.z).normalized()
	var look_dir = Vector3(cos(facing_direction.y), 0, sin(facing_direction.x))
	#DebugHUD.AppendLine("Walljump Dot: %s" % dir)
	#if %GrabbyHand.is_grabbing():
		#DebugHUD.AppendLine("Grabbing: %s (%.1fm : %.1fm)" % [%GrabbyHand.grab_selection, %GrabbyHand.distance_to_grab(), %GrabbyHand.distance_to_owner()]) 

func _physics_process(delta: float) -> void:
	# Orientation
	move_component.facing_direction = facing_direction.x
	move_component.input_direction = movement_input.xy
	%BodyRaycasts.rotation.y = facing_direction.x

	state_machine.process_states(delta)
	
	if grabbed_body:
		var target_transform = grabbed_body.global_transform
		target_transform.origin = marker_3d.global_transform.origin
		grabbed_body.global_transform = target_transform
	get_tree().call_group("enemies", "update_target_location", global_transform.origin)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if look_input is MouseVelocityInputVector && event.is_action_pressed("debug.toggle_mouse"):
			look_input.mouse_captured = false if Input.mouse_mode == Input.MouseMode.MOUSE_MODE_CAPTURED else true
	if Input.is_action_just_pressed("player.dig"):
		if grabbed_body:
			var _grabbed_body := grabbed_body
			release_grabbed_body()
			var dir := -camera_3d.global_transform.basis.z
			_grabbed_body.apply_central_impulse(dir * THROW_FORCE)
		else:
			var collider : VoxelRaycastResult = voxel_tool.raycast(global_position, marker_3d.global_position - global_position, 2.0)
			voxel_tool.mode = VoxelTool.MODE_REMOVE
			voxel_tool.do_sphere(marker_3d.global_position, 2.0)
			if collider:
				var terrain_unit = TERRAIN_UNIT.instantiate()
				terrain_unit.global_position = marker_3d.global_position
				world.add_child(terrain_unit)
	elif Input.is_action_pressed("player.grab"):
		if not grabbed_body:
			var collider = ray_cast_3d.get_collider()
			if collider and collider is RigidBody3D:
				grabbed_body = collider
				grabbed_body.freeze = true
				var mesh = grabbed_body.mesh_instance_3d
				for i in range(mesh.get_surface_override_material_count()):
					var mat : StandardMaterial3D = mesh.get_surface_override_material(i)
					if mat and mat is StandardMaterial3D:
						mat = mat.duplicate()
						var color := mat.albedo_color
						color.a = 0.5
						mat.albedo_color = color
						mesh.set_surface_override_material(i, mat)
	elif Input.is_action_just_released("player.grab"):
		for child in marker_3d.get_children():
			if child is RigidBody3D:
				grabbed_body = child
			break  # TODO: Place assert to ensure only 1 child
		if grabbed_body:
			release_grabbed_body()
	_state_input(event)

func release_grabbed_body():
	grabbed_body.freeze = false
	# Restore alpha
	var mesh = grabbed_body.mesh_instance_3d
	for i in range(mesh.get_surface_override_material_count()):
		var mat : StandardMaterial3D = mesh.get_surface_override_material(i)
		if mat and mat is StandardMaterial3D:
			mat = mat.duplicate()
			var color := mat.albedo_color
			color.a = 1
			mat.albedo_color = color
			mesh.set_surface_override_material(i, mat)
	grabbed_body = null

###############################################
# Public functions

func update_minimap(origin: Vector3, size: Vector3) -> void:
	%ClientHUD.tween_minimap_camera(origin, size)

func is_client() -> bool:
	return true

#func add_usable(u: Usable, index: int) -> void:
	#%UsableManager.set_usable(u, index)
	#%UsableManager.switch_usable(index)

###############################################
# State processing functions

var _tween_collision_height: Tween

func _state_entry(state: PlayerState, data: Dictionary = {}) -> void:
	# print(state.name)
	
	if $CollisionShape3D.shape.height != state.collision_height:
		if _tween_collision_height and _tween_collision_height.is_running():
			_tween_collision_height.kill()
		_tween_collision_height = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_tween_collision_height.tween_property($CollisionShape3D.shape, "height", state.collision_height, 0.15)

	for entry: PlayerState.Entries in state.entries:
		match entry:
			PlayerState.Entries.JUMP_IMPULSE:
				var y_impulse = 1.0
				var xz_impulse = 1.0
				if data.has(&"jump_y_impulse"): y_impulse = data[&"jump_y_impulse"]
				if data.has(&"jump_xz_impulse"): xz_impulse = data[&"jump_xz_impulse"]
				move_component.jump_impulse(y_impulse, xz_impulse)
			
			PlayerState.Entries.WALLJUMP_IMPULSE:
				move_component.impulse(up_direction, 5.50)
				move_component.impulse(_wall_facing_normal, 10.50)

			PlayerState.Entries.FACE_WALL:
				# _facing_tween = get_tree().create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
				# _facing_tween.tween_property(self, "facing_direction", _get_wall_facing_direction(), .5)
				facing_direction = _get_wall_facing_direction()
			
			PlayerState.Entries.FACE_PERPENDICULAR_TO_WALL:
				var target_dir: Vector3 = _get_perpendicular_wall_facing_direction()
				var target_facedir: Vector2 = Vector2(atan2(target_dir.x, target_dir.z), 0.0)

				# Set up tween
				#_facing_tween = get_tree().create_tween()
				#_facing_tween.tween_property(self, "facing_direction", target_facedir+Vector2(0.0, 0.15), .120) \
					#.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
				#_facing_tween.chain().tween_property(self, "facing_direction", target_facedir, .5) \
					#.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
				#
				#facing_direction = facing_direction - Vector2(0.0, 0.25)
				facing_direction = target_facedir
				_wallrun_direction = -target_dir
			
			PlayerState.Entries.VFX_WORLD_MODEL_FACE_WALL:
				visual_component.rotation.y = _get_wall_facing_direction().x

			PlayerState.Entries.LEDGE_SNAP:
				var ledge_pos: Vector3 = _get_ledge_position()
				position = Vector3(position.x, ledge_pos.y - 1.0, position.z)
			
			PlayerState.Entries.RESET_VELOCITY:
				velocity = Vector3.ZERO
				move_component._velocity = Vector3.ZERO
			
			PlayerState.Entries.RESET_JUMPS:
				_jumps = _max_jumps
			
			#PlayerState.Entries.RELEASE_USABLE:
				#if %UsableManager.current_usable:
					#%UsableManager.release_usable()
		pass
	return


func _state_process(state: PlayerState, delta: float) -> Variant:
	for proc: PlayerState.Processes in state.processes:
		_do_processes(state, proc, delta)

	for trans: PlayerState.Transitions in state.process_transitions:
		var result = _process_transitions(trans)
		if result != Trigger.NONE:
			return result
	return null

func _do_processes(state: PlayerState, proc: PlayerState.Processes, delta: float) -> void:
	match proc:
		PlayerState.Processes.AIR:
			var gravity_factor = state.physics_gravity_factor
			var drag_factor = state.physics_drag_factor
			move_component.process_air(delta, gravity_factor, drag_factor)

		PlayerState.Processes.GROUND:
			move_component.process_ground(delta)

		PlayerState.Processes.MOVEMENT:
			move_component.process_movement(delta)

		PlayerState.Processes.PHYSICS:
			move_and_slide()
		
		PlayerState.Processes.DASHING:
			velocity = _dash_direction * 25.0
		
		PlayerState.Processes.WALLRUNNING:
			var wish_3d = Vector3(move_component.wish_direction.x, 0, move_component.wish_direction.y)
			var dot = wish_3d.dot(_wallrun_direction.normalized())
			velocity = (_wallrun_direction*7.0).move_toward(Vector3.ZERO, -max(dot, 0.0, -1.0) * delta)

		PlayerState.Processes.WALLJUMPING:
			# TODO: Fix things
			var dir = Vector3(velocity.x, 0, velocity.z).normalized()
			# var look_dir = Vector3(cos(facing_direction.x), 0, sin(facing_direction.y))
			# print(dir.dot(look_dir))
			_dash_direction = dir

		PlayerState.Processes.BATJUMP_STALL:
			velocity = velocity.lerp(Vector3.ZERO, 5.0 * delta)

const DASH_TIME = 0.1           # How long the player should stay in the dash state
const DASH_RECOVERY_TIME = 1.0  # How long should dashes recover upon landing
const END_DASH_WEIGHT = 0.375   # Slows the velocity upon dash end
const BUNNYHOP_WEIGHT = 0.700   # Yes--bunnyhopping is fun, but it's too easy
func _process_transitions(trans: PlayerState.Transitions) -> Trigger:
	match trans:
		PlayerState.Transitions.STARTED_WALK:
			if is_on_floor() && !velocity.is_zero_approx():
				return Trigger.WALKED
		
		PlayerState.Transitions.FULL_STOP:
			if is_on_floor() && velocity.is_zero_approx():
				return Trigger.STOPPED
		
		PlayerState.Transitions.LANDED:
			if is_on_floor():
				if _dashes < _max_dashes && (!_dash_recover_timer || _dash_recover_timer.time_left <= 0.0):
					_start_dash_recovery()
				velocity.x *= BUNNYHOP_WEIGHT
				velocity.z *= BUNNYHOP_WEIGHT
				return Trigger.LANDED

		PlayerState.Transitions.INTO_MID_AIR:
			if !is_on_floor():
				_jumps -= 1
				return Trigger.FELL

		PlayerState.Transitions.STARTED_FALL:
			if !is_on_floor() && velocity.y < 0.0:
				return Trigger.FELL
		
		PlayerState.Transitions.LEDGE_GRAB:
			if is_on_wall() && raycast_body_m.is_colliding() && !raycast_head.is_colliding():
				return Trigger.GRABBED_LEDGE
		
		PlayerState.Transitions.END_DASH:
			if _dash_timer.time_left <= 0.0:
				velocity *= END_DASH_WEIGHT
				if is_on_floor():
					_start_dash_recovery()
					return Trigger.LANDED
				else:
					return Trigger.FELL
		
		PlayerState.Transitions.DASH_INTO_WALLRUN:
			if _can_wallrun() && _is_dashing_along_wall():
				_wall_facing_normal = get_wall_normal()
				return Trigger.STARTED_WALLRUN
		
		PlayerState.Transitions.END_WALLRUN:
			if (!is_on_wall() && !_walls_on_sides) || velocity.is_zero_approx():
				if is_on_floor():
					return Trigger.LANDED
				else:
					_jumps -= 1
					return Trigger.FELL
				
	return Trigger.NONE


func _state_exit(state: PlayerState, trigger: Trigger) -> Dictionary:
	var result = {"new_state": null}
	var new_state: StringName
	match trigger:
		Trigger.STOPPED:
			new_state = "Idle"
			
		Trigger.WALKED:
			new_state = "Walking"

		Trigger.JUMPED:
			result["jump_y_impulse"] = 1.0
			result["jump_xz_impulse"] = 1.0
			new_state = "Jumping"
			if state.name == "WallRunning":
				new_state = "WallJumping"
			elif !is_on_floor() && state.has_connection_to("BatjumpStalling"):
				_batjump_timer = get_tree().create_timer(.35)
				_batjump_timer.timeout.connect(func(): state_machine.transition(Trigger.BATJUMPED))
				new_state = "BatjumpStalling"

		Trigger.LANDED:
			if velocity.is_zero_approx():
				new_state = "Idle"
			else:
				new_state = "Walking"
		
		Trigger.FELL:
			new_state = "Falling"
		
		Trigger.GRABBED_LEDGE:
			new_state = "GrabbingLedge"
		
		Trigger.DASHED:
			new_state = "Dashing"
		
		Trigger.STARTED_WALLRUN:
			new_state = "WallRunning"
		
		Trigger.BATJUMPED:
			result["jump_y_impulse"] = 1.0
			result["jump_xz_impulse"] = 5.50
			new_state = "Batjumping"
	
	result["new_state"] = new_state
	return result


func _state_input(event: InputEvent) -> void:
	var state: PlayerState = state_machine.current_state
	for act: PlayerState.Actions in state.actions:
		_do_actions(act, event)

func _do_actions(act: PlayerState.Actions, event: InputEvent) -> void:
	match act:
		PlayerState.Actions.JUMP:
			if _can_jump() && event.is_action_pressed("player.move_jump"):
				state_machine.transition(Trigger.JUMPED)
				_jumps -= 1

		#PlayerState.Actions.USABLES:
			#if %GrabbyHand.is_grabbing():
				#if event.is_action_pressed("player.use_main"):
					#if %GrabbyHand.is_grabbing():
						#%GrabbyHand.throw(340.0)
			#elif %UsableManager.count > 0:
				#if event.is_action_pressed("player.use_main"):
					#%UsableManager.use_usable(0)
				#if event.is_action_released("player.use_main"):
					#%UsableManager.release_usable()
			#
			#if %UsableManager.count > 0 && %UsableManager.current_usable && !%UsableManager.current_usable.is_locked():
				#if event.is_action_pressed("player.hotbar_next"):
					#%UsableManager.next_usable()
				#if event.is_action_pressed("player.hotbar_prev"):
					#%UsableManager.prev_usable()
		
		PlayerState.Actions.INTERACT:
			if event.is_action_pressed("player.interact"):
				if %GrabbyHand.is_grabbing():
					%GrabbyHand.let_go()
				else:
					%GrabbyHand.grab()
		
		PlayerState.Actions.DASH:
			# TODO: Implement dash
			if !%GrabbyHand.is_grabbing() && event.is_action_pressed("player.dash") && _can_dash():
				var dir = move_component.wish_direction
				_dash_direction = Vector3(dir.x, 0, dir.y)
				_dash_timer = get_tree().create_timer(DASH_TIME, true, true)
				state_machine.transition(Trigger.DASHED)
				_dashes -= 1
				_cancel_dash_recovery()
		
		PlayerState.Actions.CROUCH:
			if event.is_action_pressed("player.crouch"):
				pass
			if event.is_action_released("player.crouch"):
				pass


###############################################
# Signal connections

func _on_dash_recovery() -> void:
	_dashes = _max_dashes

func _on_wall_run_checks_body_entered(body: Node3D) -> void:
	_walls_on_sides = true

func _on_wall_run_checks_body_exited(body: Node3D) -> void:
	_walls_on_sides = false


###############################################
# Various

const LEDGE_RAY_LENGTH: float = 10.0
func _get_ledge_position() -> Vector3:
	var start = raycast_head.global_position + raycast_head.global_basis * raycast_head.target_position
	var end = start + Vector3.DOWN * LEDGE_RAY_LENGTH

	var result = _raycast_common(start, end, 1)
	assert(result.has("position"))
	return result["position"] + Vector3.UP

func _raycast_common(start: Vector3, end: Vector3, mask: int) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start, end, mask)
	return space_state.intersect_ray(query)

# Maybe this could be optimized?
func _get_wall_facing_direction() -> Vector2:
	var wall_norm = get_wall_normal()
	var new_basis = Basis.looking_at(-wall_norm, up_direction)
	var new_face = new_basis.get_euler()
	return Vector2(new_face.y, facing_direction.y)

func _get_perpendicular_wall_facing_direction() -> Vector3:
	print(is_on_wall())
	var wall_norm = get_wall_normal()
	var dash_norm = -_dash_direction.normalized()
	
	var wall_parallel = dash_norm - wall_norm * dash_norm.dot(wall_norm)
	var perpendicular = wall_parallel.normalized()
	
	return perpendicular

# Set up dash recovery
func _start_dash_recovery() -> void:
	_dash_recover_timer = get_tree().create_timer(DASH_RECOVERY_TIME)
	_dash_recover_timer.timeout.connect(_on_dash_recovery)

func _cancel_dash_recovery() -> void:
	if _dash_recover_timer && _dash_recover_timer.timeout.is_connected(_on_dash_recovery):
		_dash_recover_timer.timeout.disconnect(_on_dash_recovery)
		_dash_recover_timer = get_tree().create_timer(0.0)

func _can_jump() -> bool:
	return _jumps > 0

func _can_dash() -> bool:
	return _dashes > 0 && !move_component.wish_direction.is_zero_approx()

func _can_wallrun() -> bool:
	return _has_wallrun# || ConfigPlayerSave.allow_all_abilities

const WALLRUN_DOT_THRESHOLD = 0.7
func _is_dashing_along_wall() -> bool:
	if !is_on_wall_only() || _dash_direction.is_zero_approx():
		return false
	
	# Calculate the dot product between the _dash_direction and
	#  The lower the dot, the more perpendicular the vectors are
	#  The more perpendicular, the more likely you are to be running
	#  along the wall
	var wall_norm = get_wall_normal()
	var dash_norm = _dash_direction.normalized()
	var dot = abs(dash_norm.dot(wall_norm))

	return dot < WALLRUN_DOT_THRESHOLD
