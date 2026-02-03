extends Node3D

const ENEMY = preload("uid://bwxat71yiyqir")
const TERRAIN_DEBRIS = preload("uid://dfim2u8qvls45")

@export var player : CharacterBody3D = null

@export var spawn_radius := 50.0
@export var ray_height := 200.0
@export var max_attempts := 10
@export var terrain_collision_mask := 1 << 0 # layer 1

func _ready():
	if player:
		player.voxel_deleted.connect(on_voxel_deleted)

func _on_timer_timeout() -> void:
	var spawn_pos := get_random_ground_position()
	if spawn_pos != Vector3.ZERO:
		var enemy = ENEMY.instantiate()
		enemy.global_position = spawn_pos
		enemy.world = self
		add_child(enemy)

func get_random_ground_position() -> Vector3:
	var space_state = get_world_3d().direct_space_state

	for i in max_attempts:
		var x = randf_range(-spawn_radius, spawn_radius)
		var z = randf_range(-spawn_radius, spawn_radius)

		var from = Vector3(x, ray_height, z)
		var to   = Vector3(x, -ray_height, z)

		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = terrain_collision_mask
		query.hit_from_inside = false

		var result = space_state.intersect_ray(query)

		if result and result.position.distance_to(player.global_position) >= 10.0:
			return result.position + Vector3.UP * 0.1

	return Vector3.ZERO

func on_voxel_deleted(pos : Vector3):
	var debris = TERRAIN_DEBRIS.instantiate()
	add_child(debris)
	debris.global_transform.origin = pos + Vector3(1, .5, 1)
	debris.emitting = true
	debris.finished.connect(debris.queue_free)
