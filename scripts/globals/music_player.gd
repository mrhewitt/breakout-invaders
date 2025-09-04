extends Node

# dictionary of single sounds to be used with play(...)
var MUSIC = {
	theme = preload("res://assets/audio/8_bit_dub_.mp3"),
	game = preload("res://assets/audio/sfx_coin_cluster3.wav")
}

var _music_audio_player: AudioStreamPlayer = null


func play( sound_key: String ) -> void:
	if MUSIC.has(sound_key):
		play_stream( MUSIC[sound_key] )
	else:
		print("MusicPlayer: Invalid sound key for play - " + sound_key)


func play_stream(sound_to_play: AudioStream) -> void:
	# create a new audio player and put it in the scene
	# if you forgot to add_child() to incklude it in a scene
	# your sound will not play 
	if _music_audio_player == null:
		_music_audio_player = AudioStreamPlayer.new()
		get_tree().get_current_scene().add_child(_music_audio_player)
		# tell it to start playing the sound we chose
		_music_audio_player.bus = "Music"
		_music_audio_player.connect("finished", _on_music_finished)
		
	_music_audio_player.stream = sound_to_play
	_music_audio_player.play() 
	
	
func _on_music_finished() -> void:
	_music_audio_player.play()
