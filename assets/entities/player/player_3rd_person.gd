extends CharacterBody3D

signal voxel_deleted(Vector3)

@export var voxel_terrain : VoxelTerrain
@export var world : Node3D

@onready var skeleton_3d: Skeleton3D = $Skeleton3D
@onready var spring_arm_pivot: Node3D = $SpringArmPivot
@onready var spring_arm_3d: SpringArm3D = $SpringArmPivot/SpringArm3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var camera_3d: Camera3D = $SpringArmPivot/SpringArm3D/Camera3D
@onready var voxel_tool : VoxelTool = voxel_terrain.get_voxel_tool()
@onready var ray_cast_3d: RayCast3D = $Skeleton3D/RayCast3D
@onready var marker_3d: Marker3D = $Skeleton3D/BoneAttachment3D/Marker3D
@onready var area_3d: Area3D = $Skeleton3D/BoneAttachment3D/Area3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const LERP_VAL = .15
const TERRAIN_UNIT = preload("uid://d062onkv4du5i")
const THROW_FORCE : float = 18.0

var grabbed_body

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * 0.005)
		spring_arm_3d.rotate_x(-event.relative.y * 0.005)
		spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, -PI/4, PI/4)
	if Input.is_action_just_pressed("player.dig"):
		animation_tree.set("parameters/UpperBodyStateMachine/conditions/punch", true)
	elif Input.is_action_just_released("player.dig"):
		animation_tree.set("parameters/UpperBodyStateMachine/conditions/punch", false)
	if Input.is_action_just_pressed("player.grab"):
		animation_tree.set("parameters/UpperBodyStateMachine/conditions/lift", true)
		animation_tree.set("parameters/UpperBodyStateMachine/conditions/throw", false)
	elif Input.is_action_just_released("player.grab"):
		animation_tree.set("parameters/UpperBodyStateMachine/conditions/lift", false)
		animation_tree.set("parameters/UpperBodyStateMachine/conditions/throw", true)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta 
		# Lower body state machine
		animation_tree.set("parameters/LowerBodyStateMachine/conditions/jump", true)
		
		# Upper body state machine
		animation_tree.set("parameters/UpperBodyStateMachine/conditions/falling", true)
	else:
		# Lower body state machine
		if animation_tree.get("parameters/LowerBodyStateMachine/conditions/jump"):
			pass  # Play landing sound
		animation_tree.set("parameters/LowerBodyStateMachine/conditions/jump", false)
		
		# Upper body state machine
		animation_tree.set("parameters/UpperBodyStateMachine/conditions/falling", false)

	# Lower body state machine
	animation_tree.set("parameters/LowerBodyStateMachine/conditions/floor", is_on_floor())
	
	# Upper body state machine
	animation_tree.set("parameters/UpperBodyStateMachine/conditions/jump", Input.is_action_just_pressed("ui_accept") and is_on_floor())
	animation_tree.set("parameters/UpperBodyStateMachine/conditions/floor", is_on_floor())

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED, LERP_VAL)
		skeleton_3d.rotation.y = lerp_angle(skeleton_3d.rotation.y, atan2(velocity.x, velocity.z), LERP_VAL)
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)

	animation_tree.set("parameters/LowerBodyStateMachine/IdleRunBlend/blend_position", velocity.length() / SPEED)
	animation_tree.set("parameters/UpperBodyStateMachine/IdleRunBlend/blend_position", velocity.length() / SPEED)
	move_and_slide()
	get_tree().call_group("enemies", "update_target_location", global_transform.origin)


func delete_front_facing_voxel():
	# Force the ray to update
	ray_cast_3d.force_raycast_update()

	var origin := ray_cast_3d.global_position
	var forward := ray_cast_3d.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	var hit : VoxelRaycastResult = voxel_tool.raycast(origin, forward, 1.25)

	if hit == null:
		return

	voxel_tool.set_voxel(hit.position, 0)
	voxel_deleted.emit(hit.position)


func lift():
	delete_front_facing_voxel()
	var terrain_unit = TERRAIN_UNIT.instantiate()
	marker_3d.add_child(terrain_unit)
	grabbed_body = terrain_unit


func throw():
	grabbed_body.reparent(world, true)
	grabbed_body.freeze = false
	var dir := -camera_3d.global_transform.basis.z
	grabbed_body.apply_central_impulse(dir * THROW_FORCE)
