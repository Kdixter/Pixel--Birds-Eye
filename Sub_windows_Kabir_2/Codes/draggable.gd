# Filename: draggable.gd
# --- FINAL & ROBUST VERSION ---
extends Area2D

## If checked, this node can be transferred between containers.
@export var is_element: bool = false

# Tracks the highest z-index to ensure the active window is always on top.
static var top_z_index: int = 1

var is_dragging: bool = false
var offset: Vector2 = Vector2.ZERO
# Reliably holds a reference to the element's current home container.
var current_container: Area2D = null


# --- Input Handling (Handles starting and stopping the drag) ---

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# START DRAG: Left-click press inside the collision shape.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if not is_dragging:
			start_drag()

func _unhandled_input(event: InputEvent) -> void:
	# STOP DRAG: Right-click press anywhere on the screen.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if is_dragging:
			stop_drag()
			get_viewport().set_input_as_handled()


# --- Core Drag-and-Drop Logic ---

func start_drag() -> void:
	is_dragging = true
	var draggable_parent = get_parent()
	offset = get_global_mouse_position() - draggable_parent.global_position
	
	# --- LAYERING & STATE FIX ---
	# Find the parent SubWindow and bring it to the front.
	var parent_window = find_parent_sub_window()
	if parent_window:
		top_z_index += 1
		parent_window.z_index = top_z_index
		
		# If this is an element, we now reliably set its current container.
		# This is much safer than doing it in _ready().
		if is_element:
			current_container = parent_window.get_node("DropContainer")

func stop_drag() -> void:
	is_dragging = false
	if is_element:
		handle_element_drop()

func _physics_process(_delta: float) -> void:
	if is_dragging:
		get_parent().global_position = get_global_mouse_position() - offset


# --- Element-Specific Drop and Reparenting Logic ---

func handle_element_drop() -> void:
	# 1. Check if we've been dropped on a NEW valid container.
	var new_container = find_new_container()
	if new_container:
		reparent_to_container(new_container)
		return

	# 2. If not, check if we are still within our CURRENT container.
	if not is_within_current_container():
		# If we were dropped outside of all valid areas, snap back home.
		get_parent().global_position = current_container.global_position

func reparent_to_container(new_container: Area2D) -> void:
	var element_node = get_parent()
	var old_global_pos = element_node.global_position
	var new_element_container = new_container.get_node("ElementContainer")
	
	element_node.get_parent().remove_child(element_node)
	new_element_container.add_child(element_node)
	element_node.global_position = old_global_pos
	
	# Update our internal reference to our new home.
	current_container = new_container


# --- Helper Functions (More robust than before) ---

func find_new_container() -> Area2D:
	for area in get_overlapping_areas():
		if area.is_in_group("drop_container") and area != current_container:
			return area
	return null

func is_within_current_container() -> bool:
	if not current_container: return false
	
	var container_shape = current_container.get_node("CollisionShape2D")
	var container_rect = container_shape.shape.get_rect()
	var container_transform = container_shape.global_transform
	
	var global_bounds = Rect2(container_transform.origin - container_rect.size / 2, container_rect.size)
	
	return global_bounds.has_point(get_parent().global_position)

func find_parent_sub_window() -> Node2D:
	var node = get_parent()
	# Traverse up the scene tree until we find the SubWindow parent.
	while node:
		if node.is_in_group("sub_windows"):
			return node
		node = node.get_parent()
	return null
