extends Path2D
class_name TrackPath

# Implements a reusable Path2D node that when given a target node, spped and curve
# will move that target node along the curve path at given speed
# Fires a signal once path has been completly followed

## Fired once path follow path_progress becomes 1
## Argument is the velocity at which target exited the path
signal path_complete(exit_velocity: Vector2)

var path_follow: PathFollow2D
var travel_tween: Tween
var speed: float
var original_parent: Node
var target: Node2D


func follow_curve( _target: Node2D, _curve: Curve2D, _speed: float) -> void:
	original_parent = _target.get_parent()
	target = _target
	global_position = target.global_position
	rotation = target.rotation
	
	speed = _speed
	curve = _curve
	path_follow = PathFollow2D.new()
	add_child(path_follow)
	target.reparent(path_follow)
 
	# caller told us how fast to go, so work out how long it will take to 
	# travel entire path at this speed, that gives us time span for the tween
	var travel_time = curve.get_baked_length() / speed
	travel_tween = create_tween()
	travel_tween.tween_property(path_follow,'progress_ratio',1,travel_time)
	#travel_tween.tween_callback(exit_path).set_delay(travel_time)
	await travel_tween.finished
	exit_path()
	
	
# Stop path following and free resources
# Fires the path_complete with the exit velocity
# Called automatically when path end is reached, but can also be called at any point
# to cause the target to stop following the path prematurely	
func exit_path() -> void:	
	# work out how fast we were moving to complete the path
	# use vector of last potion of path to determine a velocity on exiting
	# the path, 
	#var last_point: int = curve.point_count-1
	#var path_velocity = to_global(curve.get_point_position(last_point)) - to_global(curve.get_point_position(last_point-1))
	#var path_velocity = target.global_position - to_global(curve.get_closest_point(target.global_position))
	var path_velocity = to_global( curve.sample_baked(path_follow.progress) )   - to_global( curve.sample_baked(path_follow.progress-10) )  
	# start at velocity vector we left path on
	var velocity = path_velocity.normalized() * speed

	# reparent target to its original parent node and free ourselves  
	target.reparent(original_parent)
	if travel_tween:
		travel_tween.kill()
	
	# tell subscribers our motion is complete and let them know what our exit velocity is
	path_complete.emit(velocity)
	queue_free()
