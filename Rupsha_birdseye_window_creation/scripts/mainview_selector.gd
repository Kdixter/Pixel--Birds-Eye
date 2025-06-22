extends Area2D

var selecting := false
#var out_of_bounds := false

var start := Vector2i()
var end := Vector2i()
var size := Vector2i()

var pixel_start = Vector2()
var pixel_end = Vector2()
var pixel_size = Vector2()

var tile_dim := Vector2i(40,40)
var tile_offset := Vector2(0,20)

var rect := Rect2i()

var valid_recs := Array()

signal rectangle_check()

func _input_event(_viewport, event, _shape_idx): # catches inputs to main_view window
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			selecting = true
			#print("clicking on MV")
			start = $InternalGrid.detect_pos() + Vector2i(0,-1)
		elif selecting:
			end = $InternalGrid.detect_pos()
			#print("unclicked MV")
			#print(start, end)
			selecting = false
			
			if start != end +  Vector2i(0,-1) and rect != Rect2i():
				#print(rect)
				rectangle_check.emit()
				rect = Rect2i()
		queue_redraw()
	elif selecting and event is InputEventMouseMotion:
		end = $InternalGrid.detect_pos()
		queue_redraw()

func _draw():
	if (start.x == end.x or start.y == end.y) and start != end:
		pass
		
	elif start.y < end.y and start.x < end.x and selecting:
		
		pixel_start = Vector2(start * tile_dim) + tile_offset
		
		pixel_end = Vector2(end * tile_dim) + tile_offset

		pixel_size = abs(pixel_start - pixel_end)

		rect = Rect2(pixel_start, pixel_size)

		draw_rect(rect, Color.GREEN, false, 1.0)
	
	for rec in valid_recs:
		draw_rect(rec, Color.GREEN, false, 2.0)
	
