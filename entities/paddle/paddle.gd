extends CharacterBody2D

@export var speed: float = 400.0
@export var accel: float = 20.0
@export var deccel: float = 10.0

@export_category("Oscillator")
@export var spring: float = 180.0
@export var damp: float = 7.0
@export var velocity_multiplier: float = 0.5

@onready var sprite_2d: Sprite2D = $Sprite2D

## Osicllator
var displacement: float = 0
var oscillator_velocity: float = 0


func _process(delta: float) -> void:	
	var dir: float = 0
	if Input.is_action_pressed("move_left"):
		dir = -1
	if Input.is_action_pressed("move_right"):
		dir = 1	
	
	# smoothen the movement
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, deccel * delta)
	
	# damping oscillator rotation
	oscillator_velocity += (velocity.x / speed) * velocity_multiplier
	var force = -spring * displacement + damp * oscillator_velocity
	oscillator_velocity -= force * delta
	displacement -= oscillator_velocity * delta
	
	sprite_2d.rotation = -displacement	

	
func _physics_process(delta: float) -> void:
	
	var collision = move_and_collide(velocity * delta)
	
	if not collision: return
	if collision.get_collider().is_in_group("Ball"):
		pass
		
		
