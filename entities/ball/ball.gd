extends CharacterBody2D
class_name Ball

@export var speed: float = 200

var target_velocity: Vector2
var last_edge_bumped: CollisionShape2D = null


func _ready() -> void:
	launch()


func launch() -> void:
	target_velocity = -global_transform.y * speed
	velocity = target_velocity
	rotation = velocity.angle()


func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity  * delta)
	if collision:
		reset_last_edge()
		
		var target = collision.get_collider() 
		var normal = collision.get_normal()
		target_velocity = velocity.bounce(collision.get_normal())
		
		if target.is_in_group("invader"):
			target.damage(1)
			velocity = target_velocity
		elif target.is_in_group("paddle"):
			# if we hit paddle do a normal bounce, so velocity moves immediatly to target
			velocity = target_velocity
		else:
			last_edge_bumped = target.get_child(0)
			last_edge_bumped.set_deferred('disabled',1)	
	else:
		velocity = velocity.move_toward(target_velocity, 350*delta )
		rotation = velocity.angle()
		if last_edge_bumped and velocity == target_velocity:
			reset_last_edge()
			
			
func reset_last_edge() -> void:
	if last_edge_bumped:
		last_edge_bumped.set_deferred('disabled',0)
		last_edge_bumped = null
