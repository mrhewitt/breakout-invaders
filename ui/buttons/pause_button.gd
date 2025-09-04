extends ScreenButton
class_name PauseButton

signal game_paused


func _on_pressed() -> void:
	super._on_pressed()
	game_paused.emit()	
