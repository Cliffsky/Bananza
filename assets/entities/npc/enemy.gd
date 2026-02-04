extends CharacterBody3D
class_name Enemy

@export var world: Node

@onready var mesh_instance_3d: MeshInstance3D = $enemy/Armature/Skeleton3D/MeshInstance3D
@onready var animation_player: AnimationPlayer = $enemy/AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var armature: Node3D = $enemy/Armature
@onready var physical_bone_simulator: PhysicalBoneSimulator3D = \
	$enemy/Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var timer: Timer = $Timer

enum ImpState {
	DEFAULT,
	DEAD
}

const IMP_PROJECTILE := preload("res://assets/entities/npc/imp_projectile.tscn")

const ATTACK_RANGE := 5.0
const SPEED := 1.5
const ROTATION_LERP := 1.5

var state: ImpState = ImpState.DEFAULT : 
	set(value):
		if value == state: return
		state = value
		if state == ImpState.DEAD:
			timer.start()
			animation_player.active = false
			animation_tree.active = false

var has_reached_target := false
var player_pos: Vector3 = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# For despawn animation - see _on_timer_timeout
	var mat := mesh_instance_3d.get_surface_override_material(0)
	if mat:
		mesh_instance_3d.set_surface_override_material(0, mat.duplicate())

func _physics_process(delta: float) -> void:
	if state == ImpState.DEAD:
		return

	var distance := _distance_to_player()

	_update_attack_state(distance)
	_update_movement(distance, delta)
	_update_animation()

	move_and_slide()

# --------------------------------------------------------------------

func update_target_location(target_location: Vector3) -> void:
	player_pos = target_location

func _distance_to_player() -> float:
	var to_player := player_pos - global_position
	to_player.y = 0.0
	return to_player.length()

func _update_attack_state(distance: float) -> void:
	if has_reached_target and distance > ATTACK_RANGE + 1.0:
		has_reached_target = false
		animation_tree.active = true
		return

	if not has_reached_target and distance <= ATTACK_RANGE:
		has_reached_target = true
		_on_target_reached()

func _update_movement(distance: float, delta: float) -> void:
	if has_reached_target:
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		_move_towards_player(distance)

	_apply_gravity(delta)

func _move_towards_player(distance: float) -> void:
	if distance <= 0.05:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var direction := (player_pos - global_position)
	direction.y = 0.0
	direction = direction.normalized()

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	armature.rotation.y = lerp_angle(
		armature.rotation.y,
		atan2(direction.x, direction.z),
		ROTATION_LERP
	)

func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta

func _update_animation() -> void:
	if not animation_tree.active:
		return

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	animation_tree.set(
		"parameters/BlendSpace1D/blend_position",
		horizontal_speed / SPEED
	)

# --------------------------------------------------------------------

func _on_target_reached() -> void:
	if state == ImpState.DEAD: return
	animation_tree.active = false
	animation_player.play("shoot")

func spawn_projectile() -> void:
	if not world:
		push_warning("Enemy has no world assigned")
		return

	var projectile = IMP_PROJECTILE.instantiate()
	projectile.direction = global_position.direction_to(player_pos)
	projectile.position = global_position + Vector3.UP

	world.add_child(projectile)

func _on_area_3d_body_entered(body: Node3D) -> void:
	on_violent_contact(body)


func _on_area_3d_area_entered(area: Area3D) -> void:
	on_violent_contact(area)

func on_violent_contact(collider) -> void:
	state = ImpState.DEAD
	physical_bone_simulator.physical_bones_start_simulation()

	var force := 18.0
	var hit_pos = collider.global_position

	for bone in physical_bone_simulator.get_children():
		if bone is PhysicalBone3D:
			var dir = (bone.global_position - hit_pos).normalized()
			bone.apply_impulse(dir * force)


func _on_timer_timeout() -> void:
	var tween = create_tween()
	var mat := mesh_instance_3d.get_active_material(0) as StandardMaterial3D
	if not mat:
		return

	# Tween the alpha from current to 0
	tween.tween_property(mat, "albedo_color:a", 0.0, 1.5)
	tween.play()

	# Optionally queue_free after fade
	tween.finished.connect(queue_free)
