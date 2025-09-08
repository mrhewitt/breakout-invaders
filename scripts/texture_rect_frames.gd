extends TextureRect
class_name TextureRectFrames

# Implementsa TextureRect that contains frames in same was as a Sprite2D
# using "frame" property you can manually alter the frame displayed 

@export var frame: int = 0:
	set(frame_in):
		if total_frames():
			frame = frame_in % total_frames()
			set_texture_frame(frame)
		else:
			frame = frame_in
				
@onready var frame_height: int = texture.region.size.y
@onready var frame_width: int = texture.region.size.x
@onready var vframes: int = texture.get_atlas().get_height() / frame_height
@onready var hframes: int = texture.get_atlas().get_width() / frame_width


func _ready() -> void:
	set_texture_frame(frame)
	
func set_texture_frame(frame_number: int) -> void:
	var row: int = frame_number % vframes
	var column: int = frame_number % hframes
	
	texture.region = Rect2( column*frame_width, row*frame_height, frame_width, frame_height)


func total_frames() -> int:
	return hframes * vframes
	
