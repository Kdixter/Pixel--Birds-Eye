extends Area2D

func _on_area_entered(area: Area2D) -> void:
	Globals.transfers_ele = false 
	Globals.transfers_ele = false


func _physics_process(delta):
	for area in get_overlapping_areas():
		if area.name == "left_area": 
			Globals.transfers_ele = true 
			
