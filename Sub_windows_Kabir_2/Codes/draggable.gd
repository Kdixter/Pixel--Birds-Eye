# Filename: draggable.gd
extends Area2D

# Emitted when the object is dropped onto a valid target
signal dropped_on_target(target)

var is_dragging = false
var original_parent = null

func _input_event(viewport, event, shape_idx):
	# Start dragging on left-click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		is_dragging = true
		# Bring to the front visually
		get_parent().move_child(self, -1)
		# Store original parent in case of an invalid drop
		original_parent = get_parent()

func _process(delta):
	if is_dragging:
		# The object follows the mouse
		self.global_position = get_global_mouse_position()

	# Stop dragging on mouse release
	if is_dragging and Input.is_action_just_released("ui_accept"): # "ui_accept" is usually the left mouse button
		is_dragging = false
		find_new_parent()

func find_new_parent():
	# Check all overlapping areas
	var overlapping_areas = get_overlapping_areas()
	var new_parent_target = null

	for area in overlapping_areas:
		# We assume a valid drop target has a specific group, e.g., "drop_container"
		if area.is_in_group("drop_container"):
			new_parent_target = area
			break # Found a valid target, stop searching

	if new_parent_target:
		# Reparent the element
		var old_parent = get_parent()
		old_parent.remove_child(self)
		new_parent_target.add_child(self)
		# Reset local position after reparenting
		self.position = Vector2.ZERO
	else:
		# No valid target found, return to original parent
		# (Optional: you can add logic to smoothly move it back)
		var old_parent = get_parent()
		if old_parent != original_parent: # Reparent back if needed
			old_parent.remove_child(self)
			original_parent.add_child(self)
		# You might want to snap it back to a specific position
		# For now, we'll just leave it where it was dropped
