extends Area2D
class_name HitBox2D

@export var invulnerability_time: float = 0.0
@export var _health: Health

var _invulnerable: bool
var _inv_timer: SceneTreeTimer = null

signal hit
signal healed

func damage(val: int):
    if !_inv_timer || _inv_timer.time_left <= 0.0:
        if _health:
            _health.health -= val
        hit.emit()
        _inv_timer = get_tree().create_timer(invulnerability_time)
        

func heal(val: int):
    if _health:
        _health.health += val
        healed.emit()
