extends MarginContainer

signal wave_started

const COIN_PICKUP = preload("res://entities/pickups/coin_pickup.tscn")
const COIN_RECT_ALPHA: float = 0.4

@onready var coin_counter_label: Label = %CoinCounterLabel
@onready var coin_texture_rect: TextureRect = %CoinTextureRect
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var coins_box_container: HBoxContainer = %CoinsBoxContainer
@onready var top_score_v_box_container: VBoxContainer = %TopScoreVBoxContainer
@onready var title_label: Label = %TitleLabel
@onready var play_button: ScreenButton = %PlayButton

var coin_instance: CoinPickup
var coins: int = 2
var score: int = 1200
var last_score: int = 0
var high_score: int = 0
var new_top_score: bool = false
var is_game_over: bool = false


func _ready() -> void:
	GameManager.score_updated.connect( set_score )
	GameManager.high_score_updated.connect( set_high_score )
	GameManager.coins_updated.connect( set_coins )	
	
	
func level_complete() -> void:
	is_game_over = false
	title_label.text = 'WAVE CLEARED!'
	play_button.visible = true
	accumulate_score()
	
func game_over() -> void:
	is_game_over = true
	title_label.text = 'GAME OVER!'
	play_button.visible = false
	accumulate_score()
	

func accumulate_score() -> void:
	# if high score has tracked higher than our last level complete tracked score
	# reset it to match our last tracked score so we can visually see it increate
	if high_score > last_score:
		high_score = last_score
		
	top_score_v_box_container.visible = false
	coins_box_container.visible = false
	coin_counter_label.text = ' x 0'
	score_label.text = str(last_score)
	high_score_label.text = str(high_score)
	visible = true
	
	count_score(last_score)


func count_score(points: int) -> void:
	# stop recursing when we hit our total score
	if points >= score:
		last_score = score
		start_coin_cointer()
		return
		
	points += 50
	show_score(points)
	
	await get_tree().create_timer(0.05).timeout
	count_score(points)
	

func start_coin_cointer() -> void:
	coins_box_container.visible = true
	if coins > 0:		
		coin_instance = COIN_PICKUP.instantiate()
		coin_texture_rect.get_parent().add_child(coin_instance)
		count_coins(0) 


func start_high_score_entry() -> void:
	if new_top_score:
		top_score_v_box_container.visible = true

	
func count_coins( coins_counted: int ) -> void:
	# stop recursing when we have counted all coins
	if coins_counted >= coins:
		if is_game_over:
			start_high_score_entry()
		return
		
	coins_counted += 1
	add_to_score(1000)
	coin_counter_label.text = ' x   ' + str(coins_counted)
	
	coin_texture_rect.modulate.a = 1
	coin_instance.position = coin_texture_rect.position + Vector2(24,0)
	coin_instance.scale = Vector2.ONE	
	coin_instance.modulate.a = 1
	
	var rect_tween = create_tween()
	rect_tween.tween_property(coin_texture_rect,'modulate:a',1,0.1)
	# if this is the last coin, dont module back down to faded or it looks odd
	# when reset after coin counter ends
	if coins_counted+1 < coins:
		rect_tween.tween_property(coin_texture_rect,'modulate:a',COIN_RECT_ALPHA,0.1)
	
	var tween = create_tween()
	tween.tween_property(coin_instance,'global_position:y', coin_instance.global_position.y - 128, 0.75)
	tween.parallel().tween_property(coin_instance,'modulate:a',0,0.75)
	tween.parallel().tween_property(coin_instance,'scale',Vector2(2,2),0.75)
	tween.tween_callback(count_coins.bind(coins_counted))


func add_to_score( points: int ) -> void:
	score += points
	show_score(score)
	

func show_score( points: int ) -> void:
	if points > high_score:
		high_score = points
		new_top_score = true
	score_label.text = str(points)
	high_score_label.text = str(high_score)
	
	
func set_coins(_coins: int) -> void:
	coins = _coins
	
	
func set_score( _score: int) -> void:
	score = _score
	
	
func set_high_score( _high_score: int) -> void:
	high_score = _high_score
	new_top_score = true


func _on_play_button_pressed() -> void:
	visible = false
	wave_started.emit()
