extends SubViewportContainer

@onready var _camera: Camera3D = %MinimapCamera
@onready var _origin_marker: Node3D = %MinimapOrigin

var view_orientation: Basis

var aabb: AABB :
	get(): return AABB(focal_point, view_size)

var view_size: Vector3 :
	get(): return view_size
	set(v): view_size = v

var focal_point: Vector3 :
	get(): return focal_point
	set(v): focal_point = v

var _mm_size_tween: Tween
var _mm_origin_tween: Tween

func _process(_delta: float) -> void:
	if !view_size.is_zero_approx():
		_camera.size = view_size.length()
		_camera.position = focal_point + view_orientation * -Vector3.FORWARD * view_size.length()
		_camera.basis = view_orientation
		_origin_marker.global_position = focal_point

func tween_map_view(origin: Vector3, cam_size: Vector3) -> void:
	if is_inside_tree():
		if _mm_origin_tween:
			_mm_origin_tween.kill()
		_mm_origin_tween = get_tree().create_tween()
		_mm_origin_tween.tween_property(self, "focal_point", origin, 1).set_trans(Tween.TRANS_SINE)
		
		if _mm_size_tween:
			_mm_size_tween.kill()
		_mm_size_tween = get_tree().create_tween()
		_mm_size_tween.tween_property(self, "view_size", cam_size, 1).set_trans(Tween.TRANS_SINE)
