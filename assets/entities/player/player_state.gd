extends State
class_name PlayerState

enum Entries {
    JUMP_IMPULSE,
    LEDGE_SNAP,
    FACE_WALL,
    RESET_VELOCITY,
    VFX_WORLD_MODEL_FACE_WALL,
    RESET_JUMPS,
    RELEASE_USABLE,
    FACE_PERPENDICULAR_TO_WALL,
    SHORTEN_COLLISION_SHAPE,
    WALLJUMP_IMPULSE,
}

enum Processes {
    GROUND,
    AIR,
    MOVEMENT,
    PHYSICS,
    DASHING,
    WALLRUNNING,
    WALLJUMPING,
    BATJUMP_STALL,
}

enum Transitions {
    STARTED_WALK,
    FULL_STOP,
    INTO_MID_AIR,
    STARTED_FALL,
    LANDED,
    LEDGE_GRAB,
    END_DASH,
    DASH_INTO_WALLRUN,
    END_WALLRUN,
}

enum Actions {
    JUMP,
    USABLES,
    INTERACT,
    DASH,
    CROUCH,
    BATJUMP,
}

const PLAYER_GROUP = "players"

@export var entries: Array[Entries]
@export var processes: Array[Processes]
@export var process_transitions: Array[Transitions]
@export var actions: Array[Actions]

@export_group("Physics", "physics_")
@export var physics_gravity_factor: float = 1.0
@export var physics_fiction_factor: float = 1.0
@export var physics_drag_factor: float = 1.0

@export_group("Collision", "collision_")
@export var collision_enabled: bool = true
@export var collision_height: float = 2.0

@export_group("VFX", "vfx_")
@export var vfx_world_model_lock_orientation: bool = false

func _state_entry(data: Dictionary = {}) -> void:
    if owner.is_in_group("players") && owner.has_method("_state_entry"):
        owner._state_entry(self, data)

func _state_process(delta: float) -> Variant:
    if owner.is_in_group("players") && owner.has_method("_state_process"):
        return owner._state_process(self, delta)
    return null

func _state_exit(trigger: Variant) -> Dictionary:
    if owner.is_in_group("players") && owner.has_method("_state_exit"):
        return owner._state_exit(self, trigger)
    return {"new_state": connections[0]}
