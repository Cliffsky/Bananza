extends MovementComponent3D
class_name QuakeMovementComponent3D

@export var _walkingAcceleration: float = 35.0;
@export var _walkingSpeedCap: float = 2.5;
@export var _walkingDeceleration: float = 7.0;
@export var _drag: float = .15;
@export var _jumpVelocity: float = 7.50;
@export var _jumpForwardVelocity: float = 1.0;
@export var _gravityScale: float = 2.04;

var _gravity: Vector3:
    get:
        return _parent.get_gravity()

var _jump_direction: Vector2


func process_air(delta: float, gravity_factor: float = 1.0, drag_factor: float = 1.0) -> void:
    _velocity_y += _gravity.y * _gravityScale * gravity_factor * delta
    _velocity_y = lerp(_velocity.y, 0.0, _drag * drag_factor * delta)

func  process_ground(delta: float, friction_factor: float = 1.0) -> void:
    _jump_direction = Vector2.ZERO
    _velocity_xz = _velocity_xz.lerp(Vector2.ZERO, _walkingDeceleration * friction_factor * delta)

func process_movement(delta: float, speed_factor: float = 1.0, speed_offset: float = 0.0) -> void:
    # Handle acceleration
    #  Only if the player is moving slower than the speed cap or holding any direction
    #  other than forward.
    var speedCap = max(_walkingSpeedCap * speed_factor + speed_offset, 0.0)
    if _velocity_xz.length() < speedCap + _jumpForwardVelocity \
        || _velocity_xz.normalized().dot(wish_direction) <= 0.5:
        # jumpDirDot is the dot product of the velocity direction and the wish direction
        #  It prevents the player move backwards in the air after jumping in a direction
        var jumpDirDot = 0.375
        if _jump_direction != Vector2.ZERO:
            jumpDirDot =  clamp((-_velocity_xz.normalized().dot(wish_direction) + 1.0) / 2.0, 0.375, 1.0)
        
        # Different accelearation rates in the air and on the ground
        #  Mid air acceleration is affected by jumpDirDot^2
        var acceleration = _walkingAcceleration
        if !_parent.is_on_floor():
            acceleration = _walkingAcceleration * jumpDirDot
        _velocity_xz += wish_direction * acceleration * delta

func jump_impulse(y_factor: float = 1.0, xz_factor: float = 1.0) -> void:
    _velocity_y = _jumpVelocity * y_factor
    _jump_direction = wish_direction
    if _parent.is_on_floor():
        # Add the jump forward velocity to the current velocity on the ground
        _velocity_xz += wish_direction * _jumpForwardVelocity * xz_factor
    else:
        # Set the velocity to the walking speed cap + the jump forward velocity in mid air
        _velocity_xz = wish_direction * xz_factor
