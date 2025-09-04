extends ToggleScreenButton

@export var audio_bus_name: String


func _ready() -> void:
	is_on = !AudioServer.is_bus_mute( get_bus_idx() )


func _on_pressed() -> void:
	super._on_pressed()
	AudioServer.set_bus_mute(get_bus_idx(), !is_on)


func get_bus_idx() -> int:
	return AudioServer.get_bus_index(audio_bus_name)
