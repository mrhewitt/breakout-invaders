extends Pickup
class_name HealthPickup


# overridable method for inherited scenes to implement to handle action needed when 
# player gets the pickup
func collect_pickup(_body: CharacterBody2D) -> void:
	GameManager.health += 1
	SfxPlayer.play('pickup_coin')
