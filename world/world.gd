extends Control

@onready var pause_container: MarginContainer = $PauseContainer
@onready var hud: MarginContainer = $Game/HUD
@onready var game_menu_container: MarginContainer = $GameMenuContainer
@onready var game_over_container: MarginContainer = $GameOverContainer
@onready var top_players_container: MarginContainer = $TopPlayersContainer
@onready var paddle: CharacterBody2D = $Game/Paddle
@onready var invader_grid: InvaderGrid = $Game/InvaderGrid
@onready var invader_move_timer: Timer = $Game/InvaderMoveTimer
@onready var game: Node = $Game


func _ready() -> void:
	GameManager.load_high_scores()
	GameManager.health_updated.connect(check_health)
	
	
func new_game() -> void:
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
	

func check_health(health: int) -> void:
	if health == 0:
		game_over_container.game_over()
		game.process_mode = Node.PROCESS_MODE_DISABLED
		

func _on_invader_move_timer_timeout() -> void:
	invader_grid.shuffle()
	

func _on_invader_grid_row_moved_down() -> void:
	invader_move_timer.wait_time -= 0.025


func _on_hud_pause_game() -> void:
	pause_container.pause()


func _on_game_menu_container_game_started() -> void:
	new_game()


func _on_deatch_zone_area_body_entered(body: Node2D) -> void:
	GameManager.health -= 1
	body.queue_free()


func _on_game_menu_container_top_scores() -> void:
	top_players_container.show_top_scores()


func _on_game_over_container_wave_started() -> void:
	next_wave()
