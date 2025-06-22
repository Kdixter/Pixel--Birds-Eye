extends Node2D

var window_data := Dictionary()
### IMP: This stores a dictionary, formatted as follows:
### {key: start_index of a tile in the window, value: [end_index, rectangle, [entity_rectangles]]
### Through this, it will be possible to reconstruct the background tile data for a
### window, and place the entities it encloses, correctly.


var check_rect := Rect2()
var entity_rect := Rect2()

var entity_coords := Array()
var counter := int()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	#print($main_view.start)
	pass

func locate_relative_rectangle(node, scene):
	var node_rect = node.get_node("TextureRect").get_global_rect()
	node_rect.position = scene.to_local(node_rect.position)
	
	return node_rect

func _on_main_view_rectangle_check() -> void:
	check_rect = $main_view.rect
	
	for rec in $main_view.valid_recs:
		if check_rect.intersects(rec):
			print("invalid selection")
			return
	
	
	for entity in $main_view/Entities.get_children():
		entity_rect = locate_relative_rectangle(entity, $main_view)
		
		counter = 0
		#print(entity_rect)
		
		if check_rect.encloses(entity_rect):
			counter += 1
			
		elif check_rect.intersects(entity_rect):
			print("invalid selection")
			return
		
		for rec in $main_view.valid_recs:
			if rec.encloses(entity_rect):
				counter += 1
			if counter == 2:
				print("entity found in multiple rectangles")
				return
		
	$main_view.valid_recs.append(check_rect)
	
	window_data[$main_view.start] = [$main_view.end, check_rect]
	
	
	entity_coords = []
	
	for entity in $main_view/Entities.get_children():
		entity_rect = locate_relative_rectangle(entity, $main_view)
		
		if check_rect.encloses(entity_rect):
			entity_coords.append(entity_rect)
		
	window_data[$main_view.start].append(entity_coords)
	
	print(window_data)
	#queue_redraw()

func _on_undo_button_pressed() -> void:
	var deleted_rec = $main_view.valid_recs.pop_back()
	$main_view.queue_redraw()
	
	for key in window_data:
		if window_data[key][1] == deleted_rec:
			window_data.erase(key)
