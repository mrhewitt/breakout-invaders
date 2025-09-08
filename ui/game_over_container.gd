extends MarginContainer

signal wave_started
signal game_menu
signal high_scores

const PICKUP_SPRITE_FRAMES = preload("res://resource/pickup_sprite_frames.tres")
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
@onready var menu_button: ScreenButton = %MenuButton
@onready var high_scores_button: ScreenButton = %HighScoresButton
@onready var name_text_edit: TextEdit = %NameTextEdit
@onready var name_input_h_box_container: HBoxContainer = %NameInputHBoxContainer
@onready var saving_label: Label = %SavingLabel


var coin_instance: AnimatedSprite2D
var coins: int = 2
var score: int = 1200
var last_score: int = 0
var high_score: int = 0
var new_top_score: bool = false
var is_game_over: bool = false


func _ready() -> void:
	GameManager.score_updated.connect( set_score )
	#GameManager.high_score_updated.connect( set_high_score )
	GameManager.coins_updated.connect( set_coins )	
	GameManager.top_player_updated.connect( set_high_score )
	GameManager.wave_updated.connect( new_wave )
	
	
func new_wave(wave: int) -> void:
	is_game_over = false
	
	
func wave_complete() -> void:
	is_game_over = false
	new_top_score = false
	set_ui_entry_state('WAVE CLEARED!')
	accumulate_score()


func game_over() -> void:	
	set_ui_entry_state('GAME OVER!')

	# reload high scores table so we have the most up to date list
	GameManager.load_high_scores()
	await GameManager.top_player_updated	
	
	# only flag game over here so we dont move on when top scores
	# are refreshed above
	is_game_over = true	
	accumulate_score()


func set_ui_entry_state(label: String) -> void:
	visible = true
	new_top_score = false
	title_label.text = label
	play_button.visible = false
	menu_button.visible = false
	high_scores_button.visible = false
	top_score_v_box_container.visible = false
	coins_box_container.visible = false
	score_label.text = ''
	high_score_label.text = "Loading..."

	
func enable_ui_buttons() -> void:
	play_button.visible = !is_game_over
	menu_button.visible = is_game_over
	high_scores_button.visible = is_game_over


func accumulate_score() -> void:
	# if high score has tracked higher than our last level complete tracked score
	# reset it to match our last tracked score so we can visually see it increate
	#if high_score > last_score:
	#	high_score = last_score
		
	coin_counter_label.text = ' x 0'
	score_label.text = str(last_score)
	high_score_label.text = str(high_score)
	
	count_score(last_score)


func count_score(points: int) -> void:
	# stop recursing when we hit our total score
	if points >= score:
		await get_tree().create_timer(1).timeout
		start_coin_cointer()
		return
		
	points += 50
	show_score(points)
	
	await get_tree().create_timer(0.05).timeout
	count_score(points)
	

func start_coin_cointer() -> void:
	coins_box_container.visible = true
	if coins > 0:		
		coin_instance = AnimatedSprite2D.new() #COIN_PICKUP.instantiate()
		coin_texture_rect.get_parent().add_child(coin_instance)
		coin_instance.sprite_frames = PICKUP_SPRITE_FRAMES
		coin_instance.play('coin')
		count_coins(0) 
	else:
		coin_counting_complete()
		
		
func coin_counting_complete() -> void:
	if is_game_over:
		start_high_score_entry()
	else:
		enable_ui_buttons()
		
		
func start_high_score_entry() -> void:
	if new_top_score:
		SfxPlayer.play('highscore')
		top_score_v_box_container.visible = true
	else:
		enable_ui_buttons()
		
	
func count_coins( coins_counted: int ) -> void:
	# stop recursing when we have counted all coins
	if coins_counted >= coins:
		# done with score counting, so show UI options		
		coin_counting_complete()
		return
		
	SfxPlayer.play('count_coin')
	coins_counted += 1
	add_to_score(1000)
	coin_counter_label.text = ' x   ' + str(coins_counted)
	
	coin_texture_rect.modulate.a = 1
	coin_instance.position = coin_texture_rect.position + Vector2(24,12)
	#coin_instance.global_position = coin_texture_rect.global_position
	coin_instance.scale = Vector2.ONE	
	coin_instance.modulate.a = 1
	
	var rect_tween = create_tween()
	rect_tween.tween_property(coin_texture_rect,'modulate:a',1,0.1)
	# if this is the last coin, dont module back down to faded or it looks odd
	# when reset after coin counter ends
	if coins_counted+1 < coins:
		rect_tween.tween_property(coin_texture_rect,'modulate:a',COIN_RECT_ALPHA,0.1)
	
	coin_instance.z_index = 100
	var tween = create_tween()
	tween.tween_property(coin_instance,'position:y', coin_instance.position.y - 32, 0.75)
	tween.parallel().tween_property(coin_instance,'modulate:a',0,0.75)
	tween.parallel().tween_property(coin_instance,'scale',Vector2(3,3),0.75)
	await tween.finished
	count_coins(coins_counted)


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
	
	
# handle callback from game manager when a new top score it loaded
# normally we just set the top score, but if game is over (i..e we are in
# game over mode) we move on automatically to show high score list, as user would
# have submitted his score and table updated
func set_high_score( top_player: Dictionary ) -> void:
	high_score = top_player.score
	high_score_label.text = str(high_score)
	if is_game_over:
		name_input_h_box_container.visible = true
		saving_label.visible = false
		_on_high_score_button_pressed()


func _on_play_button_pressed() -> void:
	visible = false
	wave_started.emit()


func _on_menu_button_pressed() -> void:
	visible = false
	game_menu.emit()


func _on_high_score_button_pressed() -> void:
	visible = false
	high_scores.emit()


func _on_save_score_button_pressed() -> void:
	name_input_h_box_container.visible = false
	saving_label.visible = true
	GameManager.save_high_score( name_text_edit.text, high_score )
	
