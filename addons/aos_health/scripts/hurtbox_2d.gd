@tool
extends Area2D
class_name HurtBox2D

signal hurt

@export var base_damage: int = 5
@export var damage_modifier: DamageModifier


func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _on_area_entered(a: Area2D) -> void:
    if a is HitBox2D:
        var hb: HitBox2D =  (a as HitBox2D)
        var damage = base_damage
        if damage_modifier:
            damage = damage_modifier.weigh_damage(base_damage)
        hb.damage(damage)
        hurt.emit()
    elif a is Area2D:
        pass
