extends InputVector
class_name MouseVelocityInputVector

@export var mouse_visible: bool = true:
    set(v):
        mouse_visible = v
        _update_mouse_mode()

@export var mouse_captured: bool:
    set(v):
        mouse_captured = v
        _update_mouse_mode()

var _mouse_vel: Vector2 = Vector2.ZERO
var _delta: float = 0.0

signal end_process

func _receive_vector() -> Vector3:
    if !mouse_captured:
        return Vector3.ZERO
    
    var vel: Vector2 = _mouse_vel
    return Vector3(vel.x, vel.y, 0.0)

const LOOK_SENSITIVITY_CONSTANT = 1.0/256.0
func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion && _delta > 0.0:
        await end_process
        _mouse_vel = event.screen_relative / _delta * LOOK_SENSITIVITY_CONSTANT

func _process(delta: float) -> void:
    _mouse_vel = Vector2.ZERO
    _delta = delta
    end_process.emit()

func _update_mouse_mode() -> void:
    if mouse_captured:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    elif !mouse_visible:
        Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    else:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
