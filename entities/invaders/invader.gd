extends StaticBody2D
class_name Invader

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var shuffle_speed: float = 300

var delta_x: float = 0
var delta_y: float = 0


func _ready() -> void:
	sprite_2d.frame = randi_range(0,sprite_2d.hframes-1)
	
	
func damage(amount: int) -> void:
	queue_free()


func shuffle( direction: InvaderGrid.ShuffleDirection ) -> void:
	sprite_2d.frame = (sprite_2d.frame+1) % sprite_2d.hframes
	match direction:
		InvaderGrid.ShuffleDirection.RIGHT:
			delta_x = shuffle_speed
		InvaderGrid.ShuffleDirection.LEFT:
			delta_x = -shuffle_speed
		InvaderGrid.ShuffleDirection.DOWN:
			delta_y = shuffle_speed


func _physics_process(delta: float) -> void:
	global_position.x += delta_x * delta	
	global_position.y += delta_y * delta
	delta_x = 0
	delta_y = 0
