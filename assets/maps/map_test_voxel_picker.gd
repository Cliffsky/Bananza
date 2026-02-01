extends Node3D

const SPEED = 10.0

func _ready() -> void:
	$MeshInstance3D.mesh = VoxelPicker._create_cube_mesh(1.0)

func _process(delta: float) -> void:	
	%Thing.position += Basis(Vector3.UP, %Thing.rotation.y) * %KeyInputVector.xyz * delta * SPEED
	%Thing.directional_velocity = %MouseVelocityInputVector.xy

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_action_pressed("client.pause"):
		%MouseVelocityInputVector.mouse_captured = !%MouseVelocityInputVector.mouse_captured
		%MouseVelocityInputVector.mouse_visible = !%MouseVelocityInputVector.mouse_visible
	if event is InputEventMouseButton && event.is_action_pressed("player.dig"):
		if %Thing/RayCast3D.is_colliding():
			var result = %Thing/VoxelPicker.peek(%Thing/RayCast3D.get_collision_point(), 5.0)
			#($MeshInstance3D as MeshInstance3D).mesh.free()
			$MeshInstance3D.mesh = %Thing/VoxelPicker.create_mesh_from_voxels(result, Transform3D.IDENTITY)
			#%Thing/VoxelPicker.create_mesh_from_voxels(result, Transform3D.IDENTITY)
