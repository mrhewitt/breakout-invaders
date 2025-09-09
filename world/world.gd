extends Control

const BASE_DISPLAY_HEIGHT: float = 1280

@export_category("Instantiated Scenes")
@export var paddle_scene: PackedScene
@export var invader_grid_scene: PackedScene
@export var explosion_scene: PackedScene
@export var explosion_damage_scene: PackedScene
@export var death_explosion_scene: PackedScene
@export var points_label_scene: PackedScene

@onready var pause_container: MarginContainer = $PauseContainer
@onready var hud: MarginContainer = $HUD
@onready var game_menu_container: MarginContainer = $GameMenuContainer
@onready var game_over_container: MarginContainer = $GameOverContainer
@onready var top_players_container: MarginContainer = $TopPlayersContainer
@onready var boundry_static_body: StaticBody2D = $BoundryStaticBody
@onready var death_zone_area: Area2D = $DeathZoneArea
@onready var base_background: TextureRect = $BaseBackground
@onready var score_bonus_label: Label = %ScoreBonusLabel
@onready var combo_bonus_label: Label = %ComboBonusLabel

var invader_grid: InvaderGrid = null
var is_game_over: bool = false
var paddle: Paddle = null


func _ready() -> void:
	GameManager.load_high_scores()
	GameManager.game_over.connect(_on_game_over)
	GameManager.wave_complete.connect(_on_wave_complete)
	GameManager.score_multiplier_updated.connect(_on_score_multiplier)
	GameManager.invader_combo_reached.connect(_on_invader_combo)
	GameManager.kill_combo_reached.connect(_on_kill_combo)
	
	# expand margin at top of the game if we are on a mobile device
	# this then automatically takes safe area into account, as well as removing
	# gap at bottom, the game is designed to run at a 1280 resolution, and does
	# not scale up, or invaders would have more space and game would be easier
	if GameManager.is_on_mobile():
		GameManager.safe_margin = get_viewport_rect().size.y - BASE_DISPLAY_HEIGHT
		if GameManager.safe_margin > 0:
			# move hud down
			hud.add_theme_constant_override('margin_top', GameManager.safe_margin)
			# move all bounds dow
			boundry_static_body.global_position.y += GameManager.safe_margin
			death_zone_area.global_position.y += GameManager.safe_margin
			
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
	
	paddle = paddle_scene.instantiate()
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


func _on_game_menu_container_top_scores(player_name: String) -> void:
	top_players_container.show_top_scores(player_name)


func _on_game_over_container_wave_started() -> void:
	next_wave()


func _on_game_menu() -> void:
	base_background.modulate.a = 1
	base_background.visible = true
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
	GameManager.compute_score_multiplier()


# area - powerups => so just remove
func _on_death_zone_area_area_entered(area: Area2D) -> void:
	area.queue_free()


func _on_boundry_area_body_exited(body: Node2D) -> void:
	if body is Rocket:
		body.exit_path_follow()


func _on_invader_grid_grid_cleared() -> void:
	if is_game_over:
		hud.visible = false
		game_over_container.game_over()
	else:
		paddle.queue_free()
		game_over_container.wave_complete()


func _on_score_multiplier(score_multiplier: float) -> void:
	score_bonus_label.text = "SCORE BONUS x " + str(score_multiplier)
	score_bonus_label.visible = score_multiplier > 1
	
	
func _on_invader_combo(event_position: Vector2, combo: int) -> void:
	combo_bonus_label.show_bonus("knock combo bonus")
	show_points_label(event_position,250)
	
	
func _on_kill_combo(event_position: Vector2, combo: int) -> void:
	combo_bonus_label.show_bonus("kill combo bonus")
	show_points_label(event_position,500)


func show_points_label(event_position: Vector2, points: int) -> void:
	var label = points_label_scene.instantiate()
	add_child(label)
	label.points = points
	label.global_position = event_position
