extends Area3D

@export var parent : Node = null

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fire_sfx: AudioStreamPlayer3D = $FireSFX

const SPEED = 10.0
var direction : Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if not animation_player.current_animation == "death":
		global_position += direction * SPEED * delta
	else:
		global_position += Vector3(0, 1, 0) * delta	

func _on_body_entered(_body: Node3D) -> void:
	animation_player.play("death")

func _on_despawn_timer_timeout() -> void:
	queue_free()
