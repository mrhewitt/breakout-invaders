extends MarginContainer


func pause() -> void:
	visible = true
	SfxPlayer.play("pause_in")
	get_tree().paused = true


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false
