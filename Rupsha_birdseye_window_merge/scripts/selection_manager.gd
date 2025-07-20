extends Control

var is_selecting = false
var start_pos = Vector2()
var end_pos = Vector2()
var grid_size = 40
var selection_cells = []  # Stores selected grid cells
var completed_selections = []  # Stores finalized selection regions

@onready var color_rect = $"../View"  # Ensure ColorRect exists
@onready var color_rect_area = Rect2(Vector2.ZERO, color_rect.size)  # Local bounds

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Convert global position to local
				var local_pos = color_rect.get_global_transform_with_canvas().affine_inverse() * event.position
				is_selecting = true
				start_pos = snap_to_grid(local_pos)
				selection_cells.clear()
				end_pos = start_pos
			else:
				is_selecting = false
				finalize_selection()

	elif event is InputEventMouseMotion and is_selecting:
		# Convert global position to local
		var local_pos = color_rect.get_global_transform_with_canvas().affine_inverse() * event.position
		end_pos = snap_to_grid(local_pos)
		update_selected_cells()

	queue_redraw()  # Redraw highlights

func snap_to_grid(pos: Vector2) -> Vector2:
	# Clamp position within View's bounds
	var clamped_x = clamp(pos.x, color_rect_area.position.x, color_rect_area.end.x - grid_size)
	var clamped_y = clamp(pos.y, color_rect_area.position.y, color_rect_area.end.y - grid_size)

	# Snap to grid
	clamped_x = int(clamped_x / grid_size) * grid_size
	clamped_y = int(clamped_y / grid_size) * grid_size

	return Vector2(clamped_x, clamped_y)

func update_selected_cells():
	selection_cells.clear()

	var min_x = int(min(start_pos.x, end_pos.x) / grid_size)
	var max_x = int(max(start_pos.x, end_pos.x) / grid_size)
	var min_y = int(min(start_pos.y, end_pos.y) / grid_size)
	var max_y = int(max(start_pos.y, end_pos.y) / grid_size)

	# Prevent overlapping with completed selections
	var temp_selection = Rect2(Vector2(min_x * grid_size, min_y * grid_size), Vector2((max_x - min_x + 1) * grid_size, (max_y - min_y + 1) * grid_size))
	for rect in completed_selections:
		if rect.intersects(temp_selection):
			return  # Stop updating selection if overlap detected

	# Store valid selection
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			selection_cells.append(Vector2(x * grid_size, y * grid_size))  # Convert back to pixels

func finalize_selection():
	var is_valid = true
	if selection_cells.size() > 0:
		var min_x = int(min(start_pos.x, end_pos.x) / grid_size)
		var max_x = int(max(start_pos.x, end_pos.x) / grid_size)
		var min_y = int(min(start_pos.y, end_pos.y) / grid_size)
		var max_y = int(max(start_pos.y, end_pos.y) / grid_size)
		var final_selection = Rect2(
			Vector2(min_x * grid_size, min_y * grid_size), 
			Vector2((max_x - min_x + 1) * grid_size, (max_y - min_y + 1) * grid_size)
		)
		
		for e in get_node("../Entities").get_children():
			var sprite = e.get_node("Sprite2D")
			
			print("Sprite Global Pos: ", sprite.global_position)
			print("Sprite Region Pos: ", sprite.region_rect.position)
			print("Sprite Region Size: ", sprite.region_rect.size)
			var entity_rect = Rect2(sprite.global_position - (0.5 * sprite.region_rect.size), sprite.region_rect.size)
			
			print(entity_rect)
		
		if is_valid:
			completed_selections.append(final_selection)
			print("Valid Selection.")

func _draw():
	# Draw finalized selection borders
	for rect in completed_selections:
		draw_rect(rect, Color(0.0, 1.0, 0.0), false, 3)  # Bright green border

	# Draw selection in progress with gridlines (no fill)
	if is_selecting and selection_cells.size() > 0:
		var min_x = int(min(start_pos.x, end_pos.x) / grid_size)
		var max_x = int(max(start_pos.x, end_pos.x) / grid_size)
		var min_y = int(min(start_pos.y, end_pos.y) / grid_size)
		var max_y = int(max(start_pos.y, end_pos.y) / grid_size)

		for x in range(min_x, max_x + 1):
			for y in range(min_y, max_y + 1):
				var cell_pos = Vector2(x * grid_size, y * grid_size)
				draw_rect(Rect2(cell_pos, Vector2(grid_size, grid_size)), Color(0.0, 1.0, 0.0), false, 1)  # Faint green gridlines
