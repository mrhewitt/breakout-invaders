extends StaticBody2D
class_name Invader

const INVADERS = [
	{hitpoints = 1, points =  50},
	{hitpoints = 1, points = 100},
	{hitpoints = 2, points = 150},
	{hitpoints = 2, points = 200},
	{hitpoints = 3, points = 250}
]

@export var bomb_scene: PackedScene
@export var coin_scene: PackedScene

@export var invader_index: int = 0:
	set(idx):
		hit_points = INVADERS[idx].hitpoints
		points = INVADERS[idx].points
		animated_sprite_2d.animation = "invader-0" + str(idx+1)
		animated_sprite_2d.frame = randi_range(0,1)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

@export var shuffle_speed: float = 300

var delta_x: float = 0
var delta_y: float = 0
var hit_points: int = 0
var points : int = 0


func damage(amount: int) -> void:
	if hit_points:
		hit_points -= amount
		if hit_points <= 0:
			GameManager.score += points
			animated_sprite_2d.play('death')
			await animated_sprite_2d.animation_finished
			queue_free()


func spawn_coin() -> bool:
	if is_bottom_most() and GameManager.coins_left_in_wave > 0:
		spawn_pickup(coin_scene)
		GameManager.coins_left_in_wave -= 1
		return true
	else:
		return false
		
	
func shuffle( direction: InvaderGrid.ShuffleDirection ) -> void:
	if hit_points:
		animated_sprite_2d.frame = animated_sprite_2d.frame ^ 1 
		match direction:
			InvaderGrid.ShuffleDirection.RIGHT:
				delta_x = shuffle_speed
			InvaderGrid.ShuffleDirection.LEFT:
				delta_x = -shuffle_speed
			InvaderGrid.ShuffleDirection.DOWN:
				delta_y = shuffle_speed
	
	if is_bottom_most():
		if randi_range(0,100) == 5:
			spawn_pickup(bomb_scene)
		elif randi_range(0,500) == 5:
			spawn_coin()


func _physics_process(delta: float) -> void:
	global_position.x += delta_x * delta	
	global_position.y += delta_y * delta
	delta_x = 0
	delta_y = 0


func spawn_pickup( pickup_scene: PackedScene ) -> Node2D:
	var instance = pickup_scene.instantiate()
	get_parent().add_child(instance)
	instance.global_position = global_position + Vector2(0,32)
	return instance


# look to see if we are the bottom-most invader, i.e. no one is below us
# as ray cast only masks layer 3 we dont care what it collides, if it collides
# anything there is someone under us
# note raycast is not most efficient way, tracking invaders in data structure
# would be faster, but I wanted to experiment with raycast as it has uses in other
# cases so used this game as a learning case
func is_bottom_most() -> bool:
	return !ray_cast_2d.is_colliding()
		
