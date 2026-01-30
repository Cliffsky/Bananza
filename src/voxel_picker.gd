extends Node
class_name VoxelPicker

@export var voxel_terrain: VoxelTerrain
@onready var voxel_tool: VoxelTool = voxel_terrain.get_voxel_tool()

func peek(origin: Vector3, radius: float) -> PackedInt32Array:
	var arr: Array[int]
	var diameter: int = floori(radius) * 2
	var i_origin: Vector3i = Vector3i(origin)
	for xoff: int in range(diameter):
		for yoff: int in range(diameter):
			for zoff: int in range(diameter):
				var v_off: Vector3i = Vector3i(xoff,yoff,zoff) - Vector3i.ONE * floori(radius)
				var peek_v: Vector3i = i_origin + v_off
				arr.append(voxel_tool.get_voxel(peek_v))
	
	return PackedInt32Array(arr)
