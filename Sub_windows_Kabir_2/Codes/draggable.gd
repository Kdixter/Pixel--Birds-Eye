# Filename: draggable.gd
# --- CORRECTED AND FINAL SCRIPT ---
extends Area2D

# Use an export variable to tell the script if it's controlling an element or a window.
# In the editor, check this box for the Draggable node inside Element.tscn,
# and leave it unchecked for the Draggable node inside SubWindow.tscn.
@export var is_element: bool = false

var is_dragging = false
var original_parent_node = null # This will be the ElementContainer

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	# Use the built-in event system to handle both press and release.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# --- START DRAGGING ---
			is_dragging = true
			
			# Store the original parent (the ElementContainer)
			if is_element:
				original_parent_node = get_parent().get_parent() # Draggable -> Element -> ElementContainer
			
			# Bring the whole object (SubWindow or Element scene) to the front
			get_parent().z_index = 10
			
		elif event.is_released():
			# --- STOP DRAGGING ---
			if not is_dragging:
				return

			is_dragging = false
			get_parent().z_index = 0 # Return to default render layer
			
			# Only elements should try to find a new parent. Windows just stop.
			if is_element:
				find_new_parent()


func _physics_process(delta: float) -> void:
	if is_dragging:
		# IMPORTANT: Move the PARENT NODE (the whole Element or SubWindow scene), not just the Area2D.
		get_parent().global_position = get_global_mouse_position()


func find_new_parent() -> void:
	var overlapping_areas = get_overlapping_areas()
	var new_container_target = null

	# Find the first valid drop container we are overlapping with.
	for area in overlapping_areas:
		if area.is_in_group("drop_container"):
			# Get the ElementContainer node from the SubWindow's DropContainer
			new_container_target = area.get_node("ElementContainer")
			break

	if new_container_target and new_container_target != original_parent_node:
		# --- VALID DROP: REPARENT THE ELEMENT ---
		var element_node = get_parent() # The Element scene itself
		
		# Remove the element from its old parent (the old ElementContainer)
		element_node.get_parent().remove_child(element_node)
		
		# Add it to the new parent (the new ElementContainer)
		new_container_target.add_child(element_node)
		
		# Center the element in its new home
		element_node.position = Vector2.ZERO
	else:
		# --- INVALID DROP: RETURN TO ORIGINAL PARENT ---
		# If no valid new parent was found, smoothly return to where it started.
		# This prevents elements from being stranded.
		get_parent().position = Vector2.ZERO
