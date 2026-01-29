##  State
##  An class representing a state in the StateMachine node.

@icon("../assets/State.svg")
extends Resource
class_name State

@export_group("State info")
@export var name: StringName = "State"
@export var connections: Array[StringName] = []
var owner: Node


##  The function called upon entry of the state.
##  Parameters:
##    `data`: Entry data for the state
func _state_entry(data: Dictionary = {}) -> void:
	pass

##  The main execution of the state. This gets called by the StateMachine
##   automatically when StateMachine.process_states() is called.
##  Parameters:
##    `delta`: Delta time
##  Returns:
##    A variant that represents the transition trigger to activate on exit.
##     If null, the state will stay on this state.
##     Else, the state will transition into a new state using _state_exit()
func _state_process(delta: float) -> Variant:
	return null


##  The function called upon exiting the state. This function is responsible
##     for transitioning to different states.
##  Paremeters:
##      `trigger`: The transition state to use.
##  Returns:
##    A dictionary to be used in the next state in _state_entry(). For this
##     state transition to work, the returning dicitonary must have a StringName
##     key `new_state` set to the name of the state you want to transition to.
func _state_exit(trigger: Variant) -> Dictionary:
	return {"new_state": connections[0]}

##  Returns whether this state is connected to the provided state
##  Parameters:
##  	`connection`: The state you want to check a connection to
##  Returns:
##    True if the state is connected to the provided state. Otherwise,
##	   it returns false.
func has_connection_to(connection: StringName) -> bool:
	return connections.has(connection)


#   State your rights!
### - AoS
