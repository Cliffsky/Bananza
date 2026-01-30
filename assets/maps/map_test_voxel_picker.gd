extends Node3D

const SPEED = 10.0

func _process(delta: float) -> void:	
	%Thing.position += Basis(Vector3.UP, %Thing.rotation.y) * %KeyInputVector.xyz * delta * SPEED
	%Thing.directional_velocity = %MouseVelocityInputVector.xy

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_action_pressed("client.pause"):
		%MouseVelocityInputVector.mouse_captured = !%MouseVelocityInputVector.mouse_captured
		%MouseVelocityInputVector.mouse_visible = !%MouseVelocityInputVector.mouse_visible
	if event is InputEventMouseButton && event.is_action_pressed("player.dig"):
		if %Thing/RayCast3D.is_colliding():
			var result = %Thing/VoxelPicker.peek(%Thing/RayCast3D.get_collision_point(), 3.0)
			print(result)
