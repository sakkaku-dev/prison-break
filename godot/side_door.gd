extends StaticBody2D

var is_opened = false

func open(immediate = false):
	if is_opened: return
	
	#if immediate:
		#animated_sprite_2d.frame = last_frame
	#else:
		#animated_sprite_2d.play("open")
	
	is_opened = true

func close(immediate = false):
	if not is_opened: return
	
	#if immediate:
		#animated_sprite_2d.frame = 0
	#else:
		#animated_sprite_2d.play_backwards("open") # TODO: different animation/pacing
		
	is_opened = false
