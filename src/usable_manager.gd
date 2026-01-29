extends Node3D
class_name UsableManager

@export var _initial_usable: Usable
@export var size: int = 5

var count: int
var usables: Array[Usable] = [null,null,null,null,null]

var current_index: int = 0:
    set(v):
        assert(v >= 0)
        assert(v < size)
        current_index = v
        _draw_current_usable()
    get:
        return current_index

var _curr_usable: Usable
var current_usable: Usable:
    get:
        return _curr_usable
            

func _ready() -> void:
    assert(get_child_count() == 0)
    usables.resize(size)
    current_index = current_index
    
func switch_usable(i: int) -> void:
    if usables[i]:
        current_index = posmod(i, size)

func next_usable() -> void:
    var i = current_index+1
    while !usables[i]:
        i = posmod(i+1, size)
    current_index = i

func prev_usable() -> void:
    var i = current_index-1
    while !usables[i]:
        i = posmod(i-1, size)
    current_index = i

func use_usable(mode: int) -> void:
    assert(current_usable)
    current_usable.use(mode)

func release_usable() -> void:
    assert(current_usable)
    current_usable.release()

func add_usable(u: Usable) -> void:
    for i: int in range(usables.size()):
        if !usables[i]:
            set_usable(u, i) 
            return

func set_usable(u: Usable, i: int) -> void:
    u.position = Vector3.ZERO
    usables[i] = u
    count += 1
    if u.is_inside_tree():
        u.get_parent().remove_child(u)
    

func _draw_current_usable() -> void:
    if _curr_usable && is_ancestor_of(_curr_usable):
        remove_child(_curr_usable)

    if usables.size() > 0 && usables[current_index]:
        _curr_usable = usables[current_index]
        add_child(_curr_usable)
        _curr_usable.owner = owner
        _curr_usable.process_mode = Node.PROCESS_MODE_INHERIT
        _curr_usable.draw()
    
