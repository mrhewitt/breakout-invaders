extends Node2D

signal explosions_finished

const EXPLOSION_COUNT = 8

@export var explosion_animation: SpriteFrames

@onready var viewport_size: Vector2 = get_viewport_rect().size

var explosions_done:int = 0

# wait a brief random period so explosions seem staggered
func _ready() -> void:
	for i in range(0,1+EXPLOSION_COUNT):
		play_explosion(i)
	
	
func play_explosion( idx : int ) -> void:
	await get_tree().create_timer( randf_range(0,0.5) ) 
	SfxPlayer.play_random('explosion_death')
	var sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = explosion_animation
	sprite.global_position = Vector2( idx*128, randf_range(viewport_size.y-100, viewport_size.y-64))
	sprite.animation_finished.connect(_on_animation_finished)
	add_child(sprite)
	sprite.play("default")


func _on_animation_finished() -> void:
	explosions_done += 1
	if explosions_done == EXPLOSION_COUNT:
		explosions_finished.emit()
		queue_free()
