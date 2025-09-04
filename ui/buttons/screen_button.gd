extends Button
class_name ScreenButton

# name of UI sfx to play when button is clicked
@export var click_sound: String = "click"


func _on_pressed() -> void:
	SfxPlayer.play(click_sound)
