extends StaticBody2D
class_name Invader

const INVADERS = [
	{hitpoints = 1, points =  50},
	{hitpoints = 1, points = 100},
	{hitpoints = 2, points = 150},
	{hitpoints = 2, points = 200},
	{hitpoints = 3, points = 250}
]


@export_group("Settings")
@export var shuffle_speed: float = 300
@export var invader_index: int = 0:
	set(idx):
		hit_points = INVADERS[idx].hitpoints
		points = INVADERS[idx].points
		animated_sprite_2d.animation = "invader-0" + str(idx+1)
		animated_sprite_2d.frame = randi_range(0,1)

@export_group("Instantiated Scenes")
@export var bomb_scene: PackedScene
@export var coin_scene: PackedScene
@export var health_scene: PackedScene
@export var points_label: PackedScene

@export_group("Curves")
@export var death_dive_curve: Curve2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var path_2d: Path2D = $Path2D

var delta_x: float = 0
var delta_y: float = 0
var hit_points: int = 0
var points : int = 0
var death_dive_track: TrackPath = null


func damage(amount: int) -> void:
	if hit_points:
		hit_points -= amount
		if hit_points <= 0:
			GameManager.score += points			
			spawn_points_label()
			
			SfxPlayer.play("explosion_invader")
			animated_sprite_2d.play('death')
			await animated_sprite_2d.animation_finished
			queue_free()
		else:
			modulate = Color.RED
			var tween = create_tween()
			tween.tween_property(self,"modulate", Color.WHITE,1)


func spawn_points_label() -> void:
	var label = points_label.instantiate()
	get_parent().add_child(label)
	label.global_position = global_position
	label.points = points
	

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
		# one percent chance of a bomb
		if randi_range(0,100) == 5:
			spawn_pickup(bomb_scene)
		# 1 in 500 of a coin	
		elif randi_range(0,500) == 5:
			spawn_coin()
		# 1 in 500 of health
		elif randi_range(0,500) == 5:
			spawn_pickup(health_scene)


func _physics_process(delta: float) -> void:
	#if !is_game_over:
	global_position.x += delta_x * delta	
	global_position.y += delta_y * delta
	delta_x = 0
	delta_y = 0


func spawn_pickup( pickup_scene: PackedScene ) -> Node2D:
	SfxPlayer.play("drop_bomb")
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


# when it leaves screen remove invader, only happens in end animation when 
# invaders fly down to player base
func _on_screen_exited() -> void:
	# as we are now child of dive track, this frees both invader and dive track
	death_dive_track.queue_free()


# player died so live invaders will dive in a curve down to player "base"
# wait a random amount to stagger effect 
# delay is the period to wait before starting the tween, this is sent from grid
# so all invaders start to peel off into their dive over a period of time instead
# at same time or sporadically at random, looks neater
func start_game_over_dive( delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	
	death_dive_track = TrackPath.new()
	get_parent().add_child(death_dive_track)
	death_dive_track.follow_curve(self, get_dive_path(), 600)
	# create a notified to let us know when we dived off screen so we can remove
	var notifier = VisibleOnScreenNotifier2D.new()
	notifier.screen_exited.connect(_on_screen_exited)
	add_child(notifier)
	return
	
	#process_mode = Node.PROCESS_MODE_DISABLED
	# move sprite icon onto path follow so its position is controlled by the curve
	#animated_sprite_2d.reparent(path_follow_2d)
	## 50% chance to flip the curve to other side to makes dives more varied 
	#if randi_range(0,100) <= 50:
#		flip_dive_path()
	# use a tween to move sprite along the path follow over a period of time
#	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_interval( delay )
	#tween.tween_property(path_follow_2d, "progress_ratio", 1,  randf_range(1.5,2) )


# flip sign on x value so path can be on the other side
# we do this so there can be some variation in dives the invader takes to make
# it more interesting
func get_dive_path() -> Curve2D:
	if randi_range(0,100) <= 50:
		# dive in pre-defined direction
		return death_dive_curve
	else:
		# dive to the opposite side, so flip curve horizontally
		# the curve is a shared resource, so duplicate it when we flip it
		var inverse_curve: Curve2D = Curve2D.new() 
		for i in death_dive_curve.get_point_count():
			var p = death_dive_curve.get_point_position(i)
			p.x *= -1
			inverse_curve.add_point(p) 
		return inverse_curve
