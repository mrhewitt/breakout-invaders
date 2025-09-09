extends Control

@onready var game_over_container: MarginContainer = $GameOverContainer
@onready var top_players_container: MarginContainer = $TopPlayersContainer


func _ready() -> void:
	GameManager.load_high_scores()
	await GameManager.top_player_updated
	GameManager.score = 900
	GameManager.coins = 0
	game_over_container.game_over()


func _on_game_over_container_high_scores() -> void:
	top_players_container.show_top_scores()
