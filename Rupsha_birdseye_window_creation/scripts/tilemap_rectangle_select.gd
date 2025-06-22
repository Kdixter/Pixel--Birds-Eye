extends TileMapLayer

var tile := Vector2i()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func detect_pos():
	tile = local_to_map(get_local_mouse_position())
	return tile

func global_pos(coord):
	return map_to_local(coord)
