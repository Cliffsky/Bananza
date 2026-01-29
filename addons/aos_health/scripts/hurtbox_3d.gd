@tool
extends Area3D
class_name HurtBox3D

signal hurt

@export var base_damage: int = 5
@export var damage_modifier: DamageModifier


func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _on_area_entered(a: Area3D) -> void:
    if a is HitBox3D:
        var hb: HitBox3D =  (a as HitBox3D)
        var damage = base_damage
        if damage_modifier:
            damage = damage_modifier.weigh_damage(base_damage)
        hb.damage(damage)
        hurt.emit()
    elif a is Area3D:
        pass
