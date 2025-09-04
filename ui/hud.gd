extends MarginContainer

signal pause_game

@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var coins_label: Label = %CoinsLabel
@onready var wave_label: Label = %WaveLabel
@onready var health_texture_rect: TextureRectFrames = %HealthTextureRect


func _ready() -> void:
	GameManager.health_updated.connect( set_health )
	GameManager.score_updated.connect( set_score )
	GameManager.high_score_updated.connect( set_high_score )
	GameManager.coins_updated.connect( set_coins )
	GameManager.wave_updated.connect( set_wave )


func set_health(health: int) -> void:
	health_texture_rect.frame = health
	
	
func set_score(score: int ) -> void:
	score_label.text = str(score)
		
		
func set_high_score(high_score: int ) -> void:
		high_score_label.text = str(high_score)
		
		
func set_coins(coins: int ) -> void:
	coins_label.text = str(coins)
		
		
func set_wave( wave: int ) -> void:
	wave_label.text = str(wave)
	
	
func _on_pause_button_game_paused() -> void:
	pause_game.emit()


func _on_timer_timeout() -> void:
	health_texture_rect.frame += 1
