extends Node2D

func _on_area_element_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("click"):
		Global.selected = true  
			
func _physics_process(delta: float) -> void:
	if Global.selected and Global.frozen:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			Global.selected = false 
