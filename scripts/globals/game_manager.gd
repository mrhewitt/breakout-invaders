extends Node

signal health_updated(health: int)
signal score_updated(score: int)
signal high_score_updated(high_score: int)
signal coins_updated(coins: int)
signal wave_updated(wave: int)
signal top_player_updated(top_player: Dictionary)
signal game_over
signal wave_complete

var health: int = 6:
	set(health_in):
		health = clampi(health_in,0,6)
		health_updated.emit(health)
		if health == 0:
			game_over.emit()

var score: int = 0:
	set(score_in):
		score = score_in
		if high_score < score:
			high_score = score
		score_updated.emit(score)
		
var high_score: int = 0:
	set(high_score_in):
		high_score = high_score_in
		high_score_updated.emit(high_score)
		
var coins: int = 0:
	set(coins_in):
		coins = coins_in
		coins_updated.emit(coins)
		
var wave: int = 1:
	set(wave_in):
		wave = wave_in
		wave_updated.emit(wave)
		# get one more coin than current wave number every wave,
		# so 2 coins in wave 1, 3 coins in wave 2 etc etc
		coins_left_in_wave = wave + 1
		
var top_player: Dictionary:
	set(top):
		top_player_updated.emit(top)


var high_score_list: Array[Dictionary] = [{name="Bob",score=10223},{name="Adian1",score=3912},{name="Predator88518",score=324}]
# tracks number of coins that can still be spawned in the current wave
# dec this each time a coin is dropped
var coins_left_in_wave: int = 0

# main container for all invders,rockets,bombs, etc
var invader_grid: InvaderGrid = null


func new_game() -> void:
	invader_grid.clear()
	score = 0
	coins = 0
	wave = 1
	
	
func get_api_key() -> String:
	var file_path = "res://assets/data/api_key.txt" # Adjust path as needed
	var file = FileAccess.open(file_path, FileAccess.READ)

	if file:
		var key:String = file.get_as_text().strip_edges() # Reads the entire file as a single string
		file.close()
		#print("API KEY: >>>>>" + key + "<<<<<")
		return key
	else:
		return ""
		

func load_high_scores() -> void:
	set_high_score_list([{name="Bob",score=10223},{name="Adian1",score=3912},{name="Predator88518",score=324}])
	return
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	# Perform a GET request. The URL below returns JSON as of writing.
	var api_key: String = "X-Master-key: " + get_api_key()
	var error = http_request.request(			\
		"https://api.jsonbin.io/v3/b/68b974cfd0ea881f4071608d?meta=false",			\
		[api_key, "X-Bin-Meta:false"]
	)
	if error != OK:
		print("An error occurred in the HTTP request.")		


func save_high_score( name: String, score: int ) -> void:
	high_score_list.append( {name=name, score=score} )
	high_score_list.sort_custom( sort_high_scores )
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	# Perform a GET request. The URL below returns JSON as of writing.
	var api_key: String = "X-Master-key: " + get_api_key()
	var error = http_request.request(			\
		"https://api.jsonbin.io/v3/b/68b974cfd0ea881f4071608d?meta=false",			\
		[api_key, "X-Bin-Meta:false"],			\
		HTTPClient.Method.METHOD_PUT,
		
	)


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# parse json into an array of score dictionaries ...
	# [ {name:xxx, score:000.00},..]
	var scores = json.get_data()
	set_high_score_list(scores)
	
	
func set_high_score_list( _scores: Array ) -> void:
	# parse into high score array, Godot does not like to assign it direct, plus
	# by default json is parsing number as floats, so force convert to int to proceed 
	for _score in _scores:
		high_score_list.append( {name=_score.name, score=int(_score.score)} )
		
	# update high scores and top player info for UI and data updates	
	if high_score_list.size():
		high_score = high_score_list[0].score
		top_player = high_score_list[0]
	else:
		high_score = 0
		
	
func sort_high_scores(score_a, score_b) -> bool:
	return score_a.score < score_b 
