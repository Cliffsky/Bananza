extends InputVector
class_name KeyInputVector

@export_custom(PROPERTY_HINT_INPUT_NAME, "") var negative_x_key: StringName = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var positive_x_key: StringName = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var negative_y_key: StringName = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var positive_y_key: StringName = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var negative_z_key: StringName = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var positive_z_key: StringName = ""

func _receive_vector() -> Vector3:
    var x = 0.0
    var y = 0.0
    var z = 0.0
    var nx = negative_x_key
    var px = positive_x_key
    var ny = negative_y_key
    var py = positive_y_key
    var nz = negative_z_key
    var pz = positive_z_key
    
    if invert_x:
        nx = positive_x_key
        px = negative_x_key
    if invert_y:
        ny = positive_y_key
        py = negative_y_key
    if invert_z:
        nz = positive_z_key
        pz = negative_z_key
    
    if !nx.is_empty() && !px.is_empty():
        x = Input.get_axis(nx, px)
    if !ny.is_empty() && !py.is_empty():
        y = Input.get_axis(ny, py)
    if !nz.is_empty() && !pz.is_empty():
        z = Input.get_axis(nz, pz)
    var v = Vector3(x,y,z)
    return v
