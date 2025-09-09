extends MarginContainer

signal game_started
signal top_scores(player_name: String)

@onready var top_player_score: Label = %TopPlayerScore


func _ready() -> void:
	top_player_score.text = "Loading scores..."
	GameManager.top_player_updated.connect(show_top_player)
	MusicPlayer.play('theme')


func _on_play_button_pressed() -> void:
	game_started.emit()
	
	var original_position = global_position
	
	# create a drop away effect
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", Vector2( global_position.x, get_viewport_rect().size.y + 50 ), 0.5)
	tween.parallel().tween_property(self,"modulate:a",0,0.6)
	
	# wait till finished then hide panel and reset size for next display
	await tween.finished
	visible = false
	modulate.a = 1
	global_position = original_position
	
	
func show_top_player(top_player: Dictionary) -> void:
	top_player_score.text = top_player.name + ": " + str(top_player.score)


func _on_top_scores_button_pressed() -> void:
	visible = false
	top_scores.emit("")
