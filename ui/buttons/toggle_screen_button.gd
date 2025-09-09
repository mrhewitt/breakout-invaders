extends ScreenButton
class_name ToggleScreenButton

@export var style_box_on: StyleBoxTexture = null
@export var style_box_off: StyleBoxTexture = null
@export var is_on: bool = true:
	set(on):
		is_on = on
		set_textures()
		
		
func _ready() -> void:
	set_textures()


func _on_pressed() -> void:
	super._on_pressed()
	
	is_on = !is_on
	set_textures()
	
	
func set_textures() -> void:
	set_button_state("normal")
	set_button_state("hover")
	set_button_state("pressed")
	set_button_state("focus")


func set_button_state( state: String ) -> void:
	if is_on:
		if style_box_on:
			add_theme_stylebox_override(state,style_box_on)
	else:
		if style_box_off:
			add_theme_stylebox_override(state,style_box_off)
