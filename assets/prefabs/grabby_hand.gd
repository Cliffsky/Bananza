extends SpringArm3D
class_name GrabbyHand3D

var grab_selection: PhysicsBody3D = null
var _locked_rotation: bool = true

## Emitted when the GrabbyHand grabs a PhysicsBody3D
signal grabbed

## Emitted when the GrabbyHand interacted with an Area3D
signal interacted


## Grabs a grabbable or interactible object
func grab() -> void:
	if !grab_selection:
		if %Hand.is_colliding():
			var collider = %Hand.get_collider(0)
			# Grab a PhysicsBody3D
			if collider is PhysicsBody3D:
				grabbed.emit()
				add_excluded_object(collider)
				if collider is RigidBody3D:
					_locked_rotation = collider.lock_rotation
					collider.lock_rotation = true

				if owner is CharacterBody3D:
					owner.add_collision_exception_with(collider)
				
				grab_selection = collider
			
			# Interact with a Area3D
			elif collider is Area3D:
				interacted.emit()

## Releases the currently grabbed object
func let_go() -> void:
	if grab_selection:
		clear_excluded_objects()
		if owner is CharacterBody3D:
			owner.remove_collision_exception_with(grab_selection)
		grab_selection.lock_rotation = _locked_rotation
		grab_selection = null

## Releases the currently grabbed object with a force
func throw(force: float) -> void:
	if grab_selection:
		clear_excluded_objects()
		if owner is CharacterBody3D:
			owner.remove_collision_exception_with(grab_selection)
		grab_selection.lock_rotation = _locked_rotation
		(grab_selection as RigidBody3D).apply_central_force(global_basis * Vector3.BACK * force)
		grab_selection = null

func _physics_process(delta: float) -> void:
	if grab_selection is RigidBody3D:
		var newpos = grab_selection.global_position.lerp(%Hand.global_position, 10.0 * delta / grab_selection.mass)
		grab_selection.linear_velocity = (newpos - grab_selection.global_position) / delta
		grab_selection.global_position = newpos
	
	# Handle too far from hand
	if grab_selection:
		if distance_to_owner_squared() >= 9.0 && distance_to_grab_squared() >= 3.0:
			let_go()

## Checks if the GrabbyHand is currently holding something
func is_grabbing() -> bool:
	return grab_selection != null

func distance_to_grab() -> float:
	return grab_selection.global_position.distance_to(%Hand.global_position)
	
func distance_to_grab_squared() -> float:
	return grab_selection.global_position.distance_squared_to(%Hand.global_position)

func distance_to_owner_squared() -> float:
	return grab_selection.global_position.distance_squared_to(global_position)

func distance_to_owner() -> float:
	return grab_selection.global_position.distance_to(global_position)
