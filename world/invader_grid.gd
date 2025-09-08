extends Node
class_name InvaderGrid

# lets subscribers know invaders have move down a row, usually so managers
# can alter difficulty, e..g making it run faster
signal row_moved_down

# let parents know the grid is now cleared of all entities
signal grid_cleared

const INVADER = preload("res://entities/invaders/invader.tscn")

const INVADER_TOP_ROW_Y = 400
const DISPLAY_WIDTH = 720

const COLUMN_SPACING = 64
const ROW_SPACING = 48
const START_COLUMN_COUNT  = 6
const START_ROW_COUNT = 5
const MAX_ROWS = 8
const MAX_COLUMNS = 10

const LEFT_MOTION_MARGIN = 32
const RIGHT_MOTION_MARGIN = 32
const SHUFFLE_DOWN_STEPS = 8


enum ShuffleDirection {LEFT, RIGHT, DOWN}

@onready var margin_x: int = (720 - ((MAX_COLUMNS-1)*COLUMN_SPACING)) / 2
@onready var invader_move_timer: Timer = $InvaderMoveTimer

var direction: ShuffleDirection = ShuffleDirection.RIGHT
var next_direction: ShuffleDirection
var steps_down: int = 0 

var wait_to_clear_grid: bool = false


func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)


func _process(delta: float) -> void:
	
	# wait until all children in grid are gone, this means entites in level
	# have finished their ending animation, so we can move on to shwo 
	# show either game over or level cleared UI
	if wait_to_clear_grid:
		if get_tree().get_nodes_in_group('invader').size() == 0:
			queue_free()
			grid_cleared.emit()		# tell game grid is clear and we can move on
	else:
		# if we are not moving down, check to see if invaders have reached
		# edge of the screen, if so change shuffle direction 
		if direction != ShuffleDirection.DOWN:
			var max_x: float = 0
			var min_x: float = 99999
		
			for invader in get_tree().get_nodes_in_group('invader'):
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
	
	# if all invaders are destroyed flag wave is over, we do it in shuffle not immediatly
	# on last invader destroyed to add a very slight delay effect to make it more natural
	if invaders.size() == 0:
		GameManager.wave_complete.emit()
		wait_to_clear_grid = true
		return
		
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
			invader_move_timer.wait_time -= 0.025
			row_moved_down.emit()
	

func clear() -> void:
	for child in get_children():
		if not child is Timer:
			child.free()


func create_invaders() -> void:
	var row_count = START_ROW_COUNT
	var column_count = START_COLUMN_COUNT
	
	# increase number of columns/rows depending on wave number
	# first few waves just add columns, once we reach max columns
	# further waves will add entire rows of invaders
	for i in range(0,GameManager.wave-1):
		if column_count < MAX_COLUMNS:
			column_count += 1
		elif row_count < MAX_ROWS:
			row_count += 1 
	
	clear()
	# add progressively harder aliens as waves progress, top row is always
	# hardest down to easiest, so on wave 1, only idx 0 (easy) aliens,
	# but if was is two invder index starts at 1, so we produce one row
	# of more difficult alient types
	var invader_idx: int = GameManager.wave - 1
	for row in range(0,row_count):
		for column in range(0,column_count):
			var invader = INVADER.instantiate()
			add_child(invader)
			invader.invader_index = invader_idx
			invader.global_position = Vector2(margin_x + (column*COLUMN_SPACING),INVADER_TOP_ROW_Y + (ROW_SPACING*row))
		invader_idx = maxi(invader_idx-1,0)


func _on_game_over() -> void:
	wait_to_clear_grid = true
	invader_move_timer.stop()
	invader_move_timer.queue_free()

	# for all the remaining invaders, start each on on its downward game over dive
	# do it so invaders do this sort of one after other, but close together, to avoid
	# jitteryness of doing it sporadically at random
	var delay: float = randf_range(0,0.05)
	for invader in get_tree().get_nodes_in_group('invader'):
		invader.start_game_over_dive(delay)
		delay += randf_range(0,0.1)
