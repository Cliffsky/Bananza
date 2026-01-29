@icon("../assets/Health.svg")
extends Resource
class_name Health

## The maximum health of the node
@export var max_health: int = 5:
	set(val):
		if val != max_health:
			max_health_changed.emit(val)
		max_health = val

## The current health of the node
var health: int = max_health :
	get:
		return health
	
	set(val):
		if val < health:
			if val <= 0:
				val = 0
				depleted.emit(val)
			damaged.emit(val)
		elif val > health:
			if val > max_health:
				val = max_health
				replenished.emit(val)
				healed.emit(val)
		health = val

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
