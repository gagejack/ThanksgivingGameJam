extends Camera2D

func shake(intensity: float, duration: float):
	var original_offset = offset
	var shake_timer = 0.0
	
	while shake_timer < duration:
		offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_timer += get_process_delta_time()
		await get_tree().process_frame
	
	offset = original_offset  # Reset to original position
