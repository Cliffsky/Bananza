extends Resource
class_name HurtBoxInfo

@export var base_damage: int = 1
@export var damage_weight: float = 1.0
@export var damage_random_weight: float = 0.0
@export var knockback: float = 0.0

func get_damage() -> int: 
	var damage: int = base_damage
	var mult: float = damage_weight + randf_range(0.0, damage_random_weight)
	return damage * mult
