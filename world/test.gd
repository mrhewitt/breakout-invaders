extends Node2D

@onready var invader_grid: InvaderGrid = $InvaderGrid

func _ready() -> void:
	invader_grid.create_invaders() 
	await get_tree().create_timer(2).timeout
	GameManager.game_over.emit()
