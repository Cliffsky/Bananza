extends CanvasLayer

var minimap_view_orientation: Basis:
	get: return %Minimap.view_orientation
	set(v): %Minimap.view_orientation = v

var game_paused: bool = false:
	set(v):
		game_paused = v
		get_tree().paused = v
		%MenuBG.visible = v
		%MainMenu.visible = v

func _ready() -> void:
	game_paused = game_paused

func _input(event: InputEvent) -> void:
	if MouseVelocityInputVector && event.is_action_pressed("client.pause"):
		game_paused = !game_paused
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if game_paused else Input.MOUSE_MODE_CAPTURED

func tween_minimap_camera(origin: Vector3, size: Vector3) -> void:
	%Minimap.tween_map_view(origin, size)
