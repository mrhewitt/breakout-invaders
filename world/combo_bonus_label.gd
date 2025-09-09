extends Label


func show_bonus( bonus: String ) -> void:
	visible = true
	label_settings.font_size = 24
	modulate.a = 1
	text = bonus.to_upper()
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	tween.parallel().tween_property(self, "label_settings:font_size", 48, 0.5)
	await tween.finished
	
	visible = false
	
