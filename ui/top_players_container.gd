extends MarginContainer

signal game_menu

@onready var names_v_box_container: VBoxContainer = %NamesVBoxContainer
@onready var scores_v_box_container: VBoxContainer = %ScoresVBoxContainer

var highlight_player_name: String = '' 

func show_top_scores(player_name: String) -> void:
	highlight_player_name = player_name
	
	clear_list(names_v_box_container)
	clear_list(scores_v_box_container)
	populate_list( GameManager.high_score_list )

	visible = true
	

func clear_list(container: Control) -> void:
	for child in container.get_children():
		child.free()
		
		
func populate_list(scores: Array) -> void:
	for score in scores:
		var name_label := create_label(names_v_box_container, HORIZONTAL_ALIGNMENT_RIGHT, score.name)
		var score_label := create_label(scores_v_box_container, HORIZONTAL_ALIGNMENT_LEFT, str(score.score))
		
		# highlight entry if we are given name and its score matches current game score
		if score.name == highlight_player_name and score.score == GameManager.score:
			var tween = create_tween().set_loops()
			tween.tween_property(name_label,'modulate', Color8(154,217,65),0.5 )
			tween.tween_property(name_label,'modulate', Color.WHITE,0.5 )
			tween.parallel().tween_property(score_label,'modulate', Color8(154,217,65),0.5 )
			tween.tween_property(score_label,'modulate', Color.WHITE,0.5 )

			
func create_label( container: Control, align: int, text: String ) -> Label:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.size_flags_horizontal = Control.SIZE_FILL	
	container.add_child(label)
	return label
	
	
func _on_menu_button_pressed() -> void:
	visible = false
	game_menu.emit()
