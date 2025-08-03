# Filename: draggable.gd
# --- FINAL VERSION WITH CORRECT STATE MANAGEMENT ---
extends Area2D

@export var is_element: bool = false

var is_dragging: bool = false
var offset: Vector2 = Vector2.ZERO
# This now tracks the element's CURRENT home, and is updated on a successful drop.
var current_container_area: Area2D = null

func _ready():
	# When the element is first created, determine its initial container.
	if is_element:
		# Path: Draggable -> Element -> ElementContainer -> DropContainer
		current_container_area = get_parent().get_parent().get_parent()

# Use _unhandled_input to catch the drop command anywhere on the screen.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if is_dragging:
			is_dragging = false
			get_parent().z_index = 0 # Return to normal visual layer.
			
			if is_element:
				handle_element_drop()
			
			get_viewport().set_input_as_handled()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		is_dragging = true
		offset = get_global_mouse_position() - get_parent().global_position
		get_parent().z_index = 10

func _physics_process(delta: float) -> void:
	if is_dragging:
		# Let the object follow the mouse freely during the drag.
		get_parent().global_position = get_global_mouse_position() - offset

func handle_element_drop():
	# 1. CHECK FOR A NEW HOME
	var overlapping_areas = get_overlapping_areas()
	var new_container_target: Area2D = null
	
	for area in overlapping_areas:
		# Find a new, valid container that is NOT our current one.
		if area.is_in_group("drop_container") and area != current_container_area:
			new_container_target = area
			break
			
	if new_container_target:
		# --- SUCCESS! TRANSFER TO NEW WINDOW ---
		reparent_to_container(new_container_target)
		# CRITICAL FIX: Update our home to the new container.
		current_container_area = new_container_target
		return

	# 2. IF NO NEW HOME, ENFORCE BOUNDARIES OF CURRENT HOME
	var container_shape_node = current_container_area.get_node("CollisionShape2D")
	var container_rect = container_shape_node.shape.get_rect()
	var container_global_pos = current_container_area.global_position
	
	# Create a Rect2 in global coordinates for our current home window.
	var global_bounds = Rect2(container_global_pos - container_rect.size / 2, container_rect.size)
	
	# If dropped outside the bounds, snap back to the center of our CURRENT home.
	if not global_bounds.has_point(get_parent().global_position):
		get_parent().global_position = current_container_area.global_position

func reparent_to_container(new_container: Area2D):
	var element_node = get_parent()
	var old_global_pos = element_node.global_position
	
	var new_element_container = new_container.get_node("ElementContainer")
	
	element_node.get_parent().remove_child(element_node)
	new_element_container.add_child(element_node)
	
	element_node.global_position = old_global_pos
