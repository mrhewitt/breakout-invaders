extends Area2D

const SPEED: float = 200

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	GameManager.game_over.connect(clear_bomb)
	GameManager.wave_complete.connect(clear_bomb)


# game is over or level cleared, so stop bomb from hurting player and fade out 
# so effect of clearing level is nicer than a hard cutover
func clear_bomb() -> void:
	collision_shape_2d.set_deferred('disabled',true)
	var tween = create_tween()
	tween.tween_property(self,'modulate:a', 0, 0.3)
	tween.tween_callback(queue_free)


func _physics_process(delta: float) -> void:
	global_position.y += SPEED * delta
	

# we hit the paddle, so take bomb damage
func _on_body_entered(body: Node2D) -> void:
	if body is Paddle:
		body.hit_by_bomb( global_position )
		queue_free()
		

# entered an area - can only be death zone, so we didnt hit anything
# bombs only damage paddle itself so just remove it
func _on_area_entered(_area: Area2D) -> void:
	queue_free()
