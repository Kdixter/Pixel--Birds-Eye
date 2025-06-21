extends "res://codes/element_movement.gd"

func _on_main_area_area_entered(area: Area2D) -> void:
	selected_element = false  

func _on_bott_area_area_entered(area: Area2D) -> void:
	selected_element = false  

func _on_left_area_area_entered(area: Area2D) -> void:
	selected_element = false   

func _on_right_area_area_entered(area: Area2D) -> void:
	selected_element = false  
