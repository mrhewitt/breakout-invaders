extends CharacterBody2D
class_name Rocket

# length of time it takes to move along entire launch path
const LAUNCH_PATH_TIME: float = 0.5

# number of invaders in a row that need to be killed to get a combo bonus
const KILL_COMBO_TARGET = 3
# number of invaders in a row that need to be at least hit to get a bonus
# killling invaders does not count to this, nor does it interrupt count
const INVADER_COMBO_TARGET = 3 


@export var speed: float = 400
@export var left_turn_curve: Curve2D
@export var right_turn_curve: Curve2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var target_velocity: Vector2
var last_edge_bumped: CollisionShape2D = null
var launch_tween: Tween = null
var path_to_track: TrackPath = null


# track how many invaders in a row we have killed
# without touching sides or another alient
var kill_combo: int = 0

# how many invaders we bounced off without touching sides
var invader_combo: int = 0


func _ready() -> void:
	GameManager.game_over.connect(clear_rocket)
	GameManager.wave_complete.connect(clear_rocket)


# fire rocket along a curve and update counter to relflect new rocket in the air
func launch_along( launch_curve: Curve2D ) -> void:
	GameManager.compute_score_multiplier()
	start_path_follow(launch_curve, speed*1.5)
	
	
# game or wave is over, so fade rocket out so level ends neatly
func clear_rocket() -> void:
	# rocket is being removed, so take it out group and recompte mulitpler
	remove_from_group('rocket')
	GameManager.compute_score_multiplier()
	
	collision_shape_2d.set_deferred('disabled',true)
	var tween = create_tween()
	tween.tween_property(self,'modulate:a', 0, 0.3)
	tween.tween_callback(queue_free)
	

func _physics_process(delta: float) -> void:
	if path_to_track == null:
		var collision = move_and_collide(velocity  * delta)
		if collision:
			process_collision(collision)
		else:
			velocity = lerp(velocity, target_velocity, delta)
			rotation = velocity.angle()


func process_collision(collision: KinematicCollision2D) -> void:
	if collision:
		var target = collision.get_collider() 
		var normal = collision.get_normal() 
		target_velocity = velocity.bounce(collision.get_normal()).normalized() * speed  
		
		if target.is_in_group("invader"):
			# check outcome of the hit, it may be null if rocket hits
			# and invader in process of dying, so do nothing in that case
			var result: Invader.DamageResult = target.damage(1)
			if result != Invader.DamageResult.NULL:
				if result == Invader.DamageResult.KILL:
					add_kill_combo()
				else:
					add_invader_combo()
				velocity = target_velocity * 1.2
				exit_path_follow()
		elif target.is_in_group("paddle"):
			# if we hit paddle do a normal bounce, so velocity moves immediatly to target
			velocity = target_velocity * 1.5
			reset_combos()
			exit_path_follow()
		else:
			# disabled code that used a curve to turn the rocket
			# when bouncing, this looks cool but doesnt play well, feels off
			# and not break-out like, so for now to improve playability going
			# back to doing a regular bounce
			# @see also enable extra exit boundary in world.gd
			velocity = target_velocity
			reset_combos()
			return
			
			# disabled for now
			if path_to_track == null:
				var curve = left_turn_curve
				if normal.y == 1:
					if velocity.x > 0:
						curve = right_turn_curve
				elif normal.x == -1:
					if velocity.y > 0:
						curve = right_turn_curve
				elif velocity.y < 0:
					curve = right_turn_curve
				start_path_follow(curve, speed * 1.2)


func add_kill_combo() -> void:
	kill_combo += 1
	print("Kill combo" , kill_combo)
	if kill_combo >= KILL_COMBO_TARGET:
		GameManager.kill_combo_reached.emit(global_position, kill_combo)
		kill_combo = 0


func add_invader_combo() -> void:
	invader_combo += 1
	print("invader combo" , kill_combo)
	if invader_combo >= INVADER_COMBO_TARGET:
		GameManager.invader_combo_reached.emit(global_position, invader_combo)
		invader_combo = 0
		
			
func reset_combos() -> void:
	kill_combo = 0
	invader_combo = 0


func turn_around() -> void:
	start_path_follow(left_turn_curve, speed)


func start_path_follow( curve: Curve2D, _speed: float ) -> void:
	path_to_track = TrackPath.new()
	path_to_track.path_complete.connect(_on_path_follow_complete)
	GameManager.invader_grid.add_child(path_to_track)
	path_to_track.follow_curve(self,curve,_speed)


func exit_path_follow() -> void:
	if path_to_track:
		path_to_track.exit_path()


func _on_path_follow_complete( exit_velocity: Vector2 ) -> void:
	velocity = exit_velocity
	# move towards are default velocity if we were moving faster in path
	target_velocity = velocity.normalized() * speed
	path_to_track = null
	# only activate paddle collision make on path complete, this has effect
	# only launch, as we dont want paddle to bump rocket as it launches
	#collision_mask |= 1


func reset_last_edge() -> void:
	if last_edge_bumped:
		last_edge_bumped.set_deferred('disabled',0)
		last_edge_bumped = null
