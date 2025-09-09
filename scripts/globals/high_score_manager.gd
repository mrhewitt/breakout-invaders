extends Node

# High Score Maanager
# @todo  -  Port code from GameManager to more resuable manager here

# prefix/suffixes for usernames in case player does not enter anything
# for his name we will generate a random one
const PREFIX: Array[String] = [
	"Dark",
	"Zany",
	"Giggle",
	"Bad",
	"Hairy",
	"Frosted",
	"Wobbly",
	"Wacky",
	"Sir",
	"Miss",
	"Dancing",
	"Captain",
	"Ninja",
	"Grumpy"
]

const SUFFIX: Array[String] = [
	"Banana",
	"Zuchini",
	"Jelly",
	"Cupcake",
	"Potato",
	"Noodles",
	"Taco",
	"Penguin",
	"Turtle",
	"Chicken",
	"Wombat",
	"Goose"
]


func get_random_player_name() -> String:
	return PREFIX.pick_random() + " " + SUFFIX.pick_random()
