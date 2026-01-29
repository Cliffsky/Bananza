extends CanvasLayer

@export var title_screen_flag: bool:
    get: return title_screen_flag
    set(v): 
        title_screen_flag = v
        %NewGameButton.visible = v
        %LoadGameButton.visible = v
        %ResumeButton.visible = !v

@onready var _version_label: Label = %VersionLabel

signal closed()


func _ready() -> void:
    var name = ProjectSettings.get_setting("application/config/name")
    var ver = ProjectSettings.get_setting("application/config/version")
    _version_label.text = "%s ver. %s" % [name, ver]
    title_screen_flag = title_screen_flag


func _on_new_game_button_pressed() -> void:
    #MapManager.ChangeMap("hub_map")
    pass


func _on_quit_button_pressed():
    get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _on_quit_game_button_pressed() -> void:
    #MapManager.ChangeMap("title_screen")
    pass


func _on_resume_pressed() -> void:
    closed.emit()
