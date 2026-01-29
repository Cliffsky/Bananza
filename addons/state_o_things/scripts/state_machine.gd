### StateMachine
#   A finite state machine organized by State resources

@icon("../assets/StateMachine.svg")
extends Node
class_name StateMachine

@export var _init_state: StringName
@export var _states: Array[State]

var _init = false
var initialized: bool:
    get: return _init

var current_state: State:
    get: return _current

var state_name: StringName:
    get: return _current.name

var _state_registry: Dictionary[String, State] = {}
var _current: State


func _ready() -> void:
    for s: State in _states:
        s.owner = owner
        _state_registry[s.name] = s
        if s.name == _init_state:
            _current = s
    _current._state_entry()
    _init = true


##  Executes the current state of the FSM
##  Within each state node, there must exist a function called `_state_process` that returns a string to a new state
func process_states(delta: float) -> void:
    transition(_current._state_process(delta))


##  Transitions to a new state for the FSM
##  trigger: Non-negative trigger key for the state to decide which state to transition to.
func transition(trigger: Variant) -> void:
    if trigger != null:
        var data: Dictionary = _current._state_exit(trigger)	
        assert(data.has("new_state"))
        assert(_current.connections.has(data["new_state"]))
        assert(_state_registry.has(data["new_state"]))
        _current = _state_registry[data["new_state"]]
        _current._state_entry(data)

#   Rage against the state machine
### - AoS 
