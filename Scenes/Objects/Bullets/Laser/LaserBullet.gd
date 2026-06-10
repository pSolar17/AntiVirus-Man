class_name LaserBullet
extends Bullet

## Bullet that is spawned as a segment of a Laser.
## It has a lifetime, after which it dies.

func _ready() -> void:
	pass

func _on_timer_timeout() -> void:
	destroy()

func destroy():
	active = false
	$LaserSprite.play("destroy")
	await $LaserSprite.animation_finished
	queue_free()
