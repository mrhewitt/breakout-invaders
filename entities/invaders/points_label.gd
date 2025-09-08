extends Node2D

@export var points: int = 0:
	set(points_in):
		label.text = str(points_in)
		
@onready var label: Label = $Label


func _ready() -> void:
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
	

func _physics_process(delta: float) -> void:	
	global_position.y -= 75*delta
