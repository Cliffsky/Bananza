@tool
@icon("../assets/HealthInstance.svg")
extends Node
class_name HealthContainer


# ====================================================
# Signals

## Emitted when the max_health property has changed. Carries the new max value.
signal max_health_changed(new_max: int)

## Emitted when the current health has increased. Carries the new health value.
signal healed(new_health: int)

## Emitted when the current health has decreased. Carries the new health value.
signal damaged(new_health: int)

## Emitted when the current health has reached its max. Carries the new health value.
signal replenished(new_health: int)

## Emitted when the current health has reached zero. Carries the new health value.
signal depleted(new_health: int)


# ====================================================
# Properties

var max_health: int:
	get: 
		return _health_resource.max_health
	set(v): 
		_health_resource.max_health = v

var health: int:
	get: 
		return _health_resource.health
	set(v): 
		_health_resource.health = v

@export var _health_resource: Health:
	set(val):
		_health_resource = val
		if Engine.is_editor_hint():
			update_configuration_warnings()
		else:
			_disconnect_signals()
			assert(_health_resource)
			_connect_signals()


# ====================================================
# Functions

func _ready() -> void:
	if !Engine.is_editor_hint():
		assert(_health_resource)
		health = max_health


func _connect_signals() -> void:
	if !_health_resource.max_health_changed.has_connections():
		_health_resource.max_health_changed.connect(_on_max_health_changed)
	if !_health_resource.healed.has_connections():
		_health_resource.healed.connect(_on_healed)
	if !_health_resource.damaged.has_connections():
		_health_resource.damaged.connect(_on_damaged)
	if !_health_resource.replenished.has_connections():
		_health_resource.replenished.connect(_on_replenished)
	if !_health_resource.depleted.has_connections():
		_health_resource.depleted.connect(_on_depleted)
	
func _disconnect_signals() -> void:
	if  _health_resource.max_health_changed.has_connections():
		_health_resource.max_health_changed.disconnect(_on_max_health_changed)
	if  _health_resource.healed.has_connections():
		_health_resource.healed.disconnect(_on_healed)
	if  _health_resource.damaged.has_connections():
		_health_resource.damaged.disconnect(_on_damaged)
	if  _health_resource.replenished.has_connections():
		_health_resource.replenished.disconnect(_on_replenished)
	if  _health_resource.depleted.has_connections():
		_health_resource.depleted.disconnect(_on_depleted)
	
func _on_max_health_changed(new_max: int) -> void:
	max_health_changed.emit(new_max)

func _on_healed(new_health: int) -> void:
	healed.emit(new_health)

func _on_damaged(new_health: int) -> void:
	damaged.emit(new_health)

func _on_replenished(new_health: int) -> void:
	replenished.emit(new_health)

func _on_depleted(new_health: int) -> void:
	depleted.emit(new_health)


func _get_configuration_warnings() -> PackedStringArray:
	if !_health_resource:
		return ["HealthInstance requires a Health resource to function!"]
	return []
