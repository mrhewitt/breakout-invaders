extends CharacterBody2D
class_name Paddle

@export_group("Settings")
@export var speed: float = 400.0
@export var accel: float = 20.0
@export var deccel: float = 10.0

@export_group("Launch Path Curves")
@export var launch_curves: Array[Curve2D]

@export_group("Instantiated Scenes")

@export var rocket_scene: PackedScene
@export var damage_decal: PackedScene
@export var explosion_scene: PackedScene


#@export_category("Oscillator")
#@export var spring: float = 180.0
#@export var damp: float = 7.0
#@export var velocity_multiplier: float = 0.5

@onready var launch_point_markers = [
	$LaunchPointLeftMarker,
	$LaunchPointRightMarker
]
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var death_animation: AnimatedSprite2D = $DeathAnimation
@onready var death_particles_2d: GPUParticles2D = $DeathParticles2D


## Osicllator
#var displacement: float = 0
#var oscillator_velocity: float = 0


func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)
	global_position = Vector2( get_viewport_rect().size.x/2, 1120 )
	

func hit_by_bomb( bomb_position: Vector2 ) -> void:
	# leave a permanent damage decal on paddle horizontally where bomb hit,
	# but ensure it is aligned exactly to top of paddle 
	var damage_instance = damage_decal.instantiate()
	add_child(damage_instance)
	damage_instance.global_position = Vector2(bomb_position.x, global_position.y)
	
	# make an explosion where bomb contacted the paddle
	var explosion_instance = explosion_scene.instantiate()
	add_child(explosion_instance)
	explosion_instance.global_position = bomb_position
	
	SfxPlayer.play("explosion_tiny")
	
	# loose health
	GameManager.health -= 1
	

func _process(delta: float) -> void:	
	var dir: float = 0
	if Input.is_action_pressed("move_left"):
		dir = -1
	if Input.is_action_pressed("move_right"):
		dir = 1	
	if Input.is_action_just_pressed("fire_action"):
		launch_rocket()
		
	# smoothen the movement
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, deccel * delta)
	
	# damping oscillator rotation
	#oscillator_velocity += (velocity.x / speed) * velocity_multiplier
	#var force = -spring * displacement + damp * oscillator_velocity
	#oscillator_velocity -= force * delta
	#displacement -= oscillator_velocity * delta
	
	#sprite_2d.rotation = -displacement	

	
func _physics_process(delta: float) -> void:	
	move_and_collide(velocity * delta)


func launch_rocket() -> void:
	var on_left_side: bool =  randi_range(0,100) < 50
	var rocket = rocket_scene.instantiate()
	var launch_position = ($LaunchPointLeftMarker if on_left_side else $LaunchPointRightMarker).global_position
	var curve = launch_curves.pick_random()
	
	# set global position _before_ we add child, or it will be added at (0,0) and when its
	# "moved" to its actual position later (e.g. if we passed launch point to launch_along which seems
	# more logical it will get an boundary area exited signal and terminate launch curve
	rocket.global_position = launch_position
	get_parent().add_child(rocket)
	rocket.launch_along( curve if !on_left_side else flip_curve(curve) )
	
	SfxPlayer.play("rocket_launch")

# flips a curve about its y-axis (so a curve to left becomes aa curve to right)
# returns a new object so original remains untounched so shared resources are not affected
func flip_curve(curve: Curve2D) -> Curve2D:
	var new_curve := Curve2D.new()
	for i in curve.point_count:
		var point := curve.get_point_position(i)
		new_curve.add_point( Vector2(-point.x,point.y) )
	return new_curve


func _on_game_over() -> void:
	sprite_2d.visible = false
	death_animation.visible = true
	death_animation.play("default")


func _on_death_animation_animation_finished() -> void:
	death_animation.visible = false
	death_particles_2d.visible = true
	death_particles_2d.emitting = true
	

# done with death, so free paddle which will also destroy
# all dynamically created decals etc
func _on_death_particles_2d_finished() -> void:
	queue_free()
