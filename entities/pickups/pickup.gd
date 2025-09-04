extends Area2D
class_name Pickup

@export var animation_name: String = ""
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.play(animation_name)


# overridable method for inherited scenes to implement to handle action needed when 
# player gets the pickup
func collect_pickup(body: CharacterBody2D) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	collect_pickup(body)
	queue_free()
