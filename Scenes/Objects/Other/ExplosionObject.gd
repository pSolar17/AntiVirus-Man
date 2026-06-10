extends Node2D

# This object is created on dying enemies and destroys itself upon completing the animation.

func _ready() -> void:
	await $AnimatedSprite2D.animation_finished
	queue_free()
