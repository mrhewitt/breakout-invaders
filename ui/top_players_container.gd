extends MarginContainer

signal game_menu

@onready var names_v_box_container: VBoxContainer = %NamesVBoxContainer
@onready var scores_v_box_container: VBoxContainer = %ScoresVBoxContainer


func show_top_scores() -> void:
	clear_list(names_v_box_container)
	clear_list(scores_v_box_container)
	populate_list(names_v_box_container, 'name', GameManager.high_score_list, HORIZONTAL_ALIGNMENT_RIGHT)
	populate_list(scores_v_box_container, 'score', GameManager.high_score_list, HORIZONTAL_ALIGNMENT_LEFT)
	visible = true
	

func clear_list(container: Control) -> void:
	for child in container.get_children():
		child.free()
		
		
func populate_list(container: Control, item_key: String, scores: Array, align: int) -> void:
	for score in scores:
		var label = Label.new()
		label.text = str(score[item_key])
		label.horizontal_alignment = align
		label.size_flags_horizontal = Control.SIZE_FILL
		container.add_child(label)


func _on_menu_button_pressed() -> void:
	visible = false
	game_menu.emit()
