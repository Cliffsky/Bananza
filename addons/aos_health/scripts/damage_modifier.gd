extends Resource
class_name DamageModifier

@export var damage_weight: float = 1.0
@export var damage_random_weight: float = 0.0

func weigh_damage(damage: int) -> int: 
	#var damage: int = base_damage
	var mult: float = damage_weight + randf_range(0.0, damage_random_weight)
	return damage * mult
