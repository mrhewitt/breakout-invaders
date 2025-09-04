extends Node
class_name InvaderGrid

signal row_moved_down

const INVADER = preload("res://entities/invaders/invader.tscn")

const DISPLAY_WIDTH = 720

const COLUMN_SPACING = 64
const ROW_SPACING = 48
const COLUMN_COUNT  = 10
const ROW_COUNT = 8

const LEFT_MOTION_MARGIN = 32
const RIGHT_MOTION_MARGIN = 32
const SHUFFLE_DOWN_STEPS = 8


enum ShuffleDirection {LEFT, RIGHT, DOWN}

@onready var margin_x: int = (720 - ((COLUMN_COUNT-1)*COLUMN_SPACING)) / 2

var direction: ShuffleDirection = ShuffleDirection.RIGHT
var next_direction: ShuffleDirection
var steps_down: int = 0 


func _process(delta: float) -> void:
	if direction != ShuffleDirection.DOWN:
		var max_x: float = 0
		var min_x: float = 99999
	
		for invader in get_children():
			max_x = maxf(invader.global_position.x,max_x)
			min_x = minf(invader.global_position.x,min_x)
		
		if (min_x < LEFT_MOTION_MARGIN and direction == ShuffleDirection.LEFT) \
		   or (max_x > DISPLAY_WIDTH-RIGHT_MOTION_MARGIN and direction == ShuffleDirection.RIGHT):
			next_direction = ShuffleDirection.LEFT if direction == ShuffleDirection.RIGHT else ShuffleDirection.RIGHT
			direction = ShuffleDirection.DOWN
			steps_down = SHUFFLE_DOWN_STEPS
			
	
# "shuffle" invaders to left or right
func shuffle() -> void:	
	var invaders = get_tree().get_nodes_in_group('invader')
	
	# if we only have as many invaders left as coin drops, force them to drop coins
	# now otherwise it may be we kill them before RNG creates a coin and player is cheated
	var force_coin_spawn: bool = GameManager.coins_left_in_wave ==  invaders.size()
	
	for invader in invaders:
		invader.shuffle(direction)
		# if we are forcing a coin spawn, try it now, method returns false if no coin
		# was spawned (i.e. not bottom-most invader) so keep force coin true until
		# spawn_coint returns true (coin spawned) then force becomes false so no further
		# spawns happen this cycle
		if force_coin_spawn:
			force_coin_spawn = !invader.spawn_coin()
			
	if steps_down > 0:
		steps_down -= 1
		if steps_down == 0:
			direction = next_direction
			row_moved_down.emit()
	

func clear() -> void:
	for invader in get_children():
		invader.free()


func create_invaders() -> void:
	clear()
	for column in range(0,COLUMN_COUNT):
		for row in range(0,ROW_COUNT):
			var invader = INVADER.instantiate()
			add_child(invader)
			invader.invader_index = 0
			invader.global_position = Vector2(margin_x + (column*COLUMN_SPACING),300 + (ROW_SPACING*row))
