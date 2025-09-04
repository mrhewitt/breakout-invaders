extends Control

@onready var invader_grid: InvaderGrid = $InvaderGrid
@onready var invader_move_timer: Timer = $InvaderMoveTimer
@onready var pause_container: MarginContainer = $PauseContainer
@onready var hud: MarginContainer = $HUD
@onready var game_menu_container: MarginContainer = $GameMenuContainer
@onready var paddle: CharacterBody2D = $Paddle

func _ready() -> void:
	GameManager.load_high_scores()

	
func new_game() -> void:
	hud.visible = true
	GameManager.new_game()
	invader_grid.create_invaders()
	paddle.visible = true
	

func _on_invader_move_timer_timeout() -> void:
	invader_grid.shuffle()


func _on_invader_grid_row_moved_down() -> void:
	invader_move_timer.wait_time -= 0.025


func _on_hud_pause_game() -> void:
	pause_container.pause()


func _on_game_menu_container_game_started() -> void:
	new_game()
