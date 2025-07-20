extends Node2D

var selected = false

func _ready() -> void:
	#update_reference_rect_size(Vector2(300, 120))
	pass

func update_reference_rect_size(new_size: Vector2i) -> void:
	
	$ReferenceRect.size = new_size
	
	$main_area/movement_col.shape = RectangleShape2D.new()
	
	$main_area/movement_col.shape.extents.x = new_size.x / 2
	
	$main_area/movement_col.global_position.x = new_size.x / 2
	
	#print($main_area/movement_col.shape.extents.x)

func _on_main_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if  Input.is_action_just_pressed("click"):
		#print('hello')
		selected = true
		
func _physics_process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
