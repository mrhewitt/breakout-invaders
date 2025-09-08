extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.frame = randi_range(0,sprite_2d.hframes)
	modulate.a = randf_range(0.4,0.6)
