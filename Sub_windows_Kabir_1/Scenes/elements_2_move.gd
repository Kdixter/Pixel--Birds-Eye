extends Node2D

func _on_element_area_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("click"):
		Globals.selected_ele_2 = true 
	 	
func _physics_process(delta: float) -> void:
	if Globals.selected_ele_2 and Globals.transfers_ele:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			Globals.selected_ele_2 = false 


	 
