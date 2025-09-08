extends Control

@export_category("Instantiated Scenes")
@export var explosion_scene: PackedScene
@export var explosion_damage_scene: PackedScene
@export var death_explosion_scene: PackedScene

@onready var pause_container: MarginContainer = $PauseContainer
@onready var hud: MarginContainer = $Game/HUD
@onready var game_menu_container: MarginContainer = $GameMenuContainer
@onready var game_over_container: MarginContainer = $GameOverContainer
@onready var top_players_container: MarginContainer = $TopPlayersContainer
@onready var paddle: CharacterBody2D = $Game/Paddle
@onready var invader_grid: InvaderGrid = $Game/InvaderGrid
@onready var invader_move_timer: Timer = $Game/InvaderMoveTimer
@onready var game: Node = $Game
@onready var boundry_static_body: StaticBody2D = $BoundryStaticBody
@onready var base_background: TextureRect = $BaseBackground


func _ready() -> void:
	GameManager.load_high_scores()
	#GameManager.health_updated.connect(check_health)
	GameManager.game_over.connect(_on_game_over)
	GameManager.invader_grid = invader_grid
	
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
	game.process_mode = Node.PROCESS_MODE_INHERIT
	start_game_wave()
	

func start_game_wave() -> void:
	invader_grid.create_invaders()
	paddle.visible = true
	game.process_mode = Node.PROCESS_MODE_INHERIT
	invader_move_timer.start()
	

func check_health(health: int) -> void:
	if health == 0:
		game_over_container.game_over()
	#	game.process_mode = Node.PROCESS_MODE_DISABLED


func _on_game_over() -> void:
	invader_move_timer.stop()
	
	var death_instance = death_explosion_scene.instantiate()
	death_instance.explosions_finished.connect(_on_death_explosions_complete)
	add_child(death_instance)
	var tween = create_tween()
	tween.tween_property(base_background,'modulate:a',0,0.5)
	
	# remove damage decals so they are not left over at end
	for child in get_tree().get_nodes_in_group("decals"):
		child.queue_free()
	
	
func _on_death_explosions_complete() -> void:
	pass
	
	
func _on_invader_move_timer_timeout() -> void:
	invader_grid.shuffle()
	

# speed up timer if invaders have moved down a row
func _on_invader_grid_row_moved_down() -> void:
	invader_move_timer.wait_time -= 0.025


func _on_hud_pause_game() -> void:
	pause_container.pause()


func _on_game_menu_container_game_started() -> void:
	new_game()


func _on_game_menu_container_top_scores() -> void:
	top_players_container.show_top_scores()


func _on_game_over_container_wave_started() -> void:
	next_wave()


func _on_game_menu() -> void:
	invader_grid.clear()
	game_menu_container.visible = true


# body - the ball =>  so take player health
func _on_death_zone_area_body_entered(body: Node2D) -> void:
	GameManager.health -= 1
	
	SfxPlayer.play("explosion_mid")
	var explosion_damage = explosion_damage_scene.instantiate()
	explosion_damage.global_position = body.global_position + Vector2(0,8)
	add_child(explosion_damage)
	
	var explosion = explosion_scene.instantiate()
	explosion.global_position = body.global_position
	add_child(explosion)
	
	body.queue_free()
	

# area - powerups => so just remove
func _on_death_zone_area_area_entered(area: Area2D) -> void:
	area.queue_free()


func _on_boundry_area_body_exited(body: Node2D) -> void:
	if body is Rocket:
		body.exit_path_follow()


func _on_invader_grid_grid_cleared() -> void:
	game_over_container.game_over()
