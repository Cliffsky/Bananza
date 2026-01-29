@tool
extends Usable
class_name Weapon

@export var _shoot_origin: Vector3:
    set(v):
        _shoot_origin = v
        _shorgin_marker.position = v

@export var shoot_info: ShootInfo:
    set(v):
        shoot_info = v
        update_configuration_warnings()

var _shorgin_marker: Marker3D


func _init() -> void:
    if Engine.is_editor_hint():
        _shorgin_marker = Marker3D.new()
        _shorgin_marker.position = _shoot_origin
        _shorgin_marker.gizmo_extents = 1.0
        add_child(_shorgin_marker)


func _ready() -> void:
    if Engine.is_editor_hint(): return
    
    if shoot_info is ShootProjectileInfo:
        if !shoot_info.projectile.is_registered():
            shoot_info.projectile.register(self)


func anim_use() -> void:
    if shoot_info is ShootHitscanInfo:
        var query = ShootInfo.HitscanQuery.new()
        query.origin = global_position + _shoot_origin
        query.basis = global_basis
        query.collision_mask = 0x7fffffff
        query.collide_with_areas = true
        query.collide_with_bodies = true
        shoot_info.fire(owner, query)
    
    if shoot_info is ShootProjectileInfo:
        var query = ShootInfo.ProjectileQuery.new()
        query.origin = global_position + _shoot_origin
        query.basis = global_basis
        query.collision_mask = 0x7fffffff
        query.collide_with_areas = true
        query.collide_with_bodies = true
        shoot_info.fire(owner, query)


func _get_configuration_warnings() -> PackedStringArray:
    var warnings = super._get_configuration_warnings()
    if !shoot_info:
        warnings.append("This node requires a ShootInfo resource!")
    return warnings
