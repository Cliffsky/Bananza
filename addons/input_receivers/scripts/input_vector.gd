@icon("../assets/Input.svg")
@abstract
extends Node
class_name InputVector

@export_range(0.001, 10.0) var sensitivity: float = 1.0
@export var deadzone: float = 0.0
@export var invert_x: bool = false
@export var invert_y: bool = false
@export var invert_z: bool = false


var _vector: Vector3 = Vector3.ZERO:
	get: 
		var v = _receive_vector()
		if v.length_squared() < deadzone * deadzone:
			return Vector3.ZERO
		return v * sensitivity

func _receive_vector() -> Vector3:
	return Vector3.ZERO

var x: float:
	get: return _vector.x

var y: float:
	get: return _vector.y

var z: float:
	get: return _vector.z


var xx: Vector2:
	get: return Vector2(_vector.x, _vector.x)

var xy: Vector2:
	get: return Vector2(_vector.x, _vector.y)

var xz: Vector2:
	get: return Vector2(_vector.x, _vector.z)

var yx: Vector2:
	get: return Vector2(_vector.y, _vector.x)

var yy: Vector2:
	get: return Vector2(_vector.y, _vector.y)

var yz: Vector2:
	get: return Vector2(_vector.y, _vector.z)

var zx: Vector2:
	get: return Vector2(_vector.z, _vector.x)

var zy: Vector2:
	get: return Vector2(_vector.z, _vector.y)

var zz: Vector2:
	get: return Vector2(_vector.z, _vector.z)


var xxx: Vector3:
	get: return Vector3(_vector.x, _vector.x, _vector.x)

var xxy: Vector3:
	get: return Vector3(_vector.x, _vector.x, _vector.y)

var xxz: Vector3:
	get: return Vector3(_vector.x, _vector.x, _vector.z)

var xyx: Vector3:
	get: return Vector3(_vector.x, _vector.y, _vector.x)

var xyy: Vector3:
	get: return Vector3(_vector.x, _vector.y, _vector.y)

var xyz: Vector3:
	get: return Vector3(_vector.x, _vector.y, _vector.z)

var xzx: Vector3:
	get: return Vector3(_vector.x, _vector.z, _vector.x)

var xzy: Vector3:
	get: return Vector3(_vector.x, _vector.z, _vector.y)

var xzz: Vector3:
	get: return Vector3(_vector.x, _vector.z, _vector.z)

var yxx: Vector3:
	get: return Vector3(_vector.y, _vector.x, _vector.x)

var yxy: Vector3:
	get: return Vector3(_vector.y, _vector.x, _vector.y)

var yxz: Vector3:
	get: return Vector3(_vector.y, _vector.x, _vector.z)

var yyx: Vector3:
	get: return Vector3(_vector.y, _vector.y, _vector.x)

var yyy: Vector3:
	get: return Vector3(_vector.y, _vector.y, _vector.y)

var yyz: Vector3:
	get: return Vector3(_vector.y, _vector.y, _vector.z)

var yzx: Vector3:
	get: return Vector3(_vector.y, _vector.z, _vector.x)

var yzy: Vector3:
	get: return Vector3(_vector.y, _vector.z, _vector.y)

var yzz: Vector3:
	get: return Vector3(_vector.y, _vector.z, _vector.z)

var zxx: Vector3:
	get: return Vector3(_vector.z, _vector.x, _vector.x)

var zxy: Vector3:
	get: return Vector3(_vector.z, _vector.x, _vector.y)

var zxz: Vector3:
	get: return Vector3(_vector.z, _vector.x, _vector.z)

var zyx: Vector3:
	get: return Vector3(_vector.z, _vector.y, _vector.x)

var zyy: Vector3:
	get: return Vector3(_vector.z, _vector.y, _vector.y)

var zyz: Vector3:
	get: return Vector3(_vector.z, _vector.y, _vector.z)

var zzx: Vector3:
	get: return Vector3(_vector.z, _vector.z, _vector.x)

var zzy: Vector3:
	get: return Vector3(_vector.z, _vector.z, _vector.y)

var zzz: Vector3:
	get: return Vector3(_vector.z, _vector.z, _vector.z)
