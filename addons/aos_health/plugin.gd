@tool
extends EditorPlugin

const HEALTH_TYPE_NAME = "Health"
const HEALTH_INSTANCE_TYPE_NAME = "HealthContainer"
const DAMAGE_MODIFIER_TYPE_NAME = "DamageModifier"
const HITBOX_2D_NAME = "HitBox2D"
const HITBOX_INFO_NAME = "HitBoxInfo"
const HURTBOX_2D_NAME = "HurtBox2D"
const HURTBOX_INFO_NAME = "HurtBoxInfo"


# func _enter_tree() -> void:
# 	add_custom_type(HEALTH_TYPE_NAME, "Resource", preload("scripts/health.gd"), preload("assets/Health.svg"))
# 	add_custom_type(HEALTH_INSTANCE_TYPE_NAME, "Node", preload("scripts/health_container.gd"), preload("assets/HealthInstance.svg"))
# 	add_custom_type(DAMAGE_MODIFIER_TYPE_NAME, "Resource", preload("scripts/damage_modifier.gd"), preload("assets/Object.svg"))
	
# 	add_custom_type(HITBOX_2D_NAME, "Area2D", preload("scripts/hitbox_2d.gd"), preload("assets/Area2D.svg"))
# 	#add_custom_type(HITBOX_INFO_NAME, "Resource", preload("scripts/hurtbox_2d.gd"), preload("assets/Area2D.svg"))
# 	add_custom_type(HURTBOX_2D_NAME, "Area2D", preload("scripts/hurtbox_2d.gd"), preload("assets/Area2D.svg"))
# 	# add_custom_type(HURTBOX_INFO_NAME, "Resource", preload("scripts/hurtbox_info.gd"), preload("assets/Object.svg"))

# func _exit_tree() -> void:
# 	remove_custom_type(HEALTH_TYPE_NAME)
# 	remove_custom_type(HEALTH_INSTANCE_TYPE_NAME)
# 	remove_custom_type(DAMAGE_MODIFIER_TYPE_NAME)
	
# 	remove_custom_type(HITBOX_2D_NAME)
# 	# remove_custom_type(HITBOX_INFO_NAME)
	
# 	remove_custom_type(HURTBOX_2D_NAME)
# 	# remove_custom_type(HURTBOX_INFO_NAME)
