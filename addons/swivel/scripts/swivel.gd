@icon("../assets/Swivel.svg")
extends Node3D
class_name Swivel

var direction: Vector2 = Vector2.ZERO
var directional_velocity: Vector2 = Vector2.ZERO
@export var dampening: float = 7.0
@export_range(0, PI) var x_clamp_range: float = PI
@export_range(0, PI) var y_clamp_range: float = PI/2.0

var _dir_vel: Vector2 = Vector2.ZERO

func _process(delta: float):
	#DebugHUD.AppendLine("DirectionalVelocity: %s" % _dir_vel)
	_dir_vel = _dir_vel.lerp(directional_velocity, min(dampening * dampening * delta, 1.0))
	#_dir_vel = directional_velocity
	
	direction -= _dir_vel * delta
	direction.x = clamp(wrap(direction.x, -PI, PI), -x_clamp_range, x_clamp_range)
	direction.y = clamp(wrap(direction.y, -PI, PI), -y_clamp_range, y_clamp_range)
	rotation.x = direction.y
	rotation.y = direction.x
	# _dir_vel = _dir_vel.move_toward(Vector2.ZERO, delta * dampening * dampening)
