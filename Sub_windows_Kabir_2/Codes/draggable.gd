# Filename: draggable.gd
# CORRECTED AND IMPROVED SCRIPT
extends Area2D

var is_dragging = false
var original_parent = null
var original_position = Vector2.ZERO

func _unhandled_input(event):
	# We use _unhandled_input to catch the mouse release event even if it happens
	# outside the object's collision shape, which is crucial.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.is_pressed() and is_dragging:
			is_dragging = false
			find_new_parent()

func _input_event(viewport, event, shape_idx):
	# Start dragging only on a left-click press inside the object's shape.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
			# Store original state to return to if the drop is invalid.
			original_parent = get_parent()
			original_position = self.position
			
			# Bring to the front visually by moving the entire parent scene (e.g., the Element or SubWindow).
			get_parent().get_parent().move_child(get_parent(), -1)

func _process(delta):
	# While dragging, the object simply follows the mouse.
	if is_dragging:
		self.global_position = get_global_mouse_position()

func find_new_parent():
	var overlapping_areas = get_overlapping_areas()
	var new_parent_target = null

	for area in overlapping_areas:
		# Find the highest valid drop container in the tree that we are overlapping with.
		if area.is_in_group("drop_container") and area != original_parent:
			new_parent_target = area
			break # Found one, stop searching.

	if new_parent_target:
		# Successfully dropped on a new valid target.
		# Reparent the object to the new window's ElementContainer.
		var new_container = new_parent_target.get_node("ElementContainer")
		original_parent.remove_child(self)
		new_container.add_child(self)
		self.position = Vector2.ZERO # Reset local position within the new container.
	else:
		# Drop was invalid (not on a valid container).
		# Return the object to its original position.
		self.position = original_position
