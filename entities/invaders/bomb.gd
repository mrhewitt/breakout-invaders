extends Area2D

const SPEED: float = 200


func _physics_process(delta: float) -> void:
	global_position.y += SPEED * delta
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("paddle"):
		body.hit_by_bomb()
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	queue_free()
