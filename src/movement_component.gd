@abstract
extends Node
class_name MovementComponent3D

@export var custom_process_integration: bool = false

var up_direction: Vector3 = Vector3.UP
var facing_direction: float
var input_direction: Vector2

var wish_direction: Vector2:
    get:
        var w = Basis(up_direction, facing_direction) * Vector3(input_direction.x, 0, input_direction.y)
        return Vector2(w.x, w.z)


var _parent: PhysicsBody3D:
    get:
        if get_parent() is PhysicsBody3D:
            return get_parent()
        push_error("Parent does not inheret PhysicsBody3D!")
        return null

var _velocity: Vector3:
    get: 
        if _parent is RigidBody3D:
            return _parent.linear_velocity
        elif _parent is CharacterBody3D:
            return _parent.velocity
        return Vector3.ZERO
    set(v): 
        if _parent is RigidBody3D:
            _parent.linear_velocity = v
        elif _parent is CharacterBody3D:
            _parent.velocity = v

var _velocity_xz: Vector2:
    get:
        return Vector2(_velocity.x, _velocity.z)
    set(v):
        _velocity.x = v.x
        _velocity.z = v.y

var _velocity_y: float:
    get:
        return _velocity.y
    set(v):
        _velocity.y = v


func process_ground(delta: float, friction_factor: float = 1.0) -> void:
    pass

func process_air(delta: float, gravity_factor: float = 1.0, drag_factor: float = 1.0) -> void:
    pass

func process_movement(delta: float, speed_factor: float = 1.0, speed_offset: float = 0.0) -> void:
    pass

func jump_impulse(y_factor: float = 1.0, xz_factor: float = 1.0) -> void:
    pass

func impulse(direction: Vector3, strength: float) -> void:
    _velocity += direction * strength


func _physics_process(delta: float) -> void:
    if !custom_process_integration:
        process_movement(delta)
        if _parent.is_on_floor():
            process_ground(delta)
        else:
            process_air(delta)
    #_parent.velocity = _velocity
