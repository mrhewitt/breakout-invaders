extends Area2D
class_name Pickup

const SPEED: float = 200

	
@export var animation_name: String = ""
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.play(animation_name)
	GameManager.game_over.connect(clear_item)


func clear_item() -> void:
	var tween = create_tween()
	tween.tween_property(self,'modulate:a', 0, 0.3)
	tween.tween_callback(queue_free)
	

func _physics_process(delta: float) -> void:
	global_position.y += SPEED * delta


# overridable method for inherited scenes to implement to handle action needed when 
# player gets the pickup
func collect_pickup(body: CharacterBody2D) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	collect_pickup(body)
	queue_free()
