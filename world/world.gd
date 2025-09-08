extends Control

@export_category("Instantiated Scenes")
@export var paddle_scene: PackedScene
@export var invader_grid_scene: PackedScene
@export var explosion_scene: PackedScene
@export var explosion_damage_scene: PackedScene
@export var death_explosion_scene: PackedScene

@onready var pause_container: MarginContainer = $PauseContainer
@onready var hud: MarginContainer = $HUD
@onready var game_menu_container: MarginContainer = $GameMenuContainer
@onready var game_over_container: MarginContainer = $GameOverContainer
@onready var top_players_container: MarginContainer = $TopPlayersContainer
@onready var boundry_static_body: StaticBody2D = $BoundryStaticBody
@onready var base_background: TextureRect = $BaseBackground

var invader_grid: InvaderGrid = null
var is_game_over: bool = false


func _ready() -> void:
	GameManager.load_high_scores()
	GameManager.game_over.connect(_on_game_over)
	GameManager.wave_complete.connect(_on_wave_complete)
	
	# create an area to mirror staticbody bounds 
	# we do this because rocket needs to enter the staticbody
	# doing its turn, so we cannot do move_and_collide when turning
	# around, but we need to know when rocket exits the collision shape
	# so we can take it off its turn and back onto a straight track
	# so this area will mirror static shape and we can use its body exited
	# signal to tell when a rocket leaves the boundry zone, and we can tell
	# it to exit the poth follow
	var boundry_area = Area2D.new()
	var area_collision_shape := CollisionPolygon2D.new()
	area_collision_shape.polygon = boundry_static_body.get_child(0).polygon
	boundry_area.collision_layer = boundry_static_body.collision_layer
	boundry_area.collision_mask = boundry_static_body.collision_mask
	boundry_area.add_child(area_collision_shape)
	boundry_area.body_exited.connect(_on_boundry_area_body_exited)
	add_child(boundry_area)
	
	
func new_game() -> void:
	base_background.modulate.a = 1
	base_background.visible = true
	hud.visible = true
	GameManager.new_game()
	start_game_wave()


func next_wave() -> void:
	GameManager.wave += 1
	start_game_wave()
	

func start_game_wave() -> void:
	is_game_over = false
	
	var paddle = paddle_scene.instantiate()
	add_child(paddle)
	
	GameManager.invader_grid = invader_grid_scene.instantiate()
	add_child(GameManager.invader_grid)
	GameManager.invader_grid.grid_cleared.connect(_on_invader_grid_grid_cleared)
	GameManager.invader_grid.create_invaders()


func _on_wave_complete() -> void:
	is_game_over = false


func _on_game_over() -> void:	
	is_game_over = true

	# create a series of explosions destroying base
	var death_instance = death_explosion_scene.instantiate()
	death_instance.explosions_finished.connect(_on_death_explosions_complete)
	add_child(death_instance)
	# fade out base graphic while explosions take place so it appears gone 
	# when UI appears
	var tween = create_tween()
	tween.tween_property(base_background,'modulate:a',0,0.5)
	
	# remove damage decals so they are not left over at end
	for child in get_tree().get_nodes_in_group("decals"):
		child.queue_free()
	
	
func _on_death_explosions_complete() -> void:
	pass


func _on_hud_pause_game() -> void:
	pause_container.pause()


func _on_game_menu_container_game_started() -> void:
	new_game()


func _on_game_menu_container_top_scores() -> void:
	top_players_container.show_top_scores()


func _on_game_over_container_wave_started() -> void:
	next_wave()


func _on_game_menu() -> void:
	game_menu_container.visible = true


# body - the ball =>  so take player health
func _on_death_zone_area_body_entered(body: Node2D) -> void:
	# destroy rocket causing the explosion 
	body.queue_free()
	
	# add a damage decal and create an explosion
	SfxPlayer.play("explosion_mid")
	var explosion_damage = explosion_damage_scene.instantiate()
	explosion_damage.global_position = body.global_position + Vector2(0,8)
	add_child(explosion_damage)
	
	var explosion:AnimatedSprite2D = explosion_scene.instantiate()
	explosion.global_position = body.global_position
	add_child(explosion)
	
	# destroy the rocket and take off some health, but wait for explosion
	# to finish animating so there is a little delay between last hit and game over
	await explosion.animation_finished
	GameManager.health -= 1


# area - powerups => so just remove
func _on_death_zone_area_area_entered(area: Area2D) -> void:
	area.queue_free()


func _on_boundry_area_body_exited(body: Node2D) -> void:
	if body is Rocket:
		body.exit_path_follow()


func _on_invader_grid_grid_cleared() -> void:
	hud.visible = false
	if is_game_over:
		game_over_container.game_over()
	else:
		game_over_container.wave_complete()
