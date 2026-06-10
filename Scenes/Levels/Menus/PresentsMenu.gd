extends Node2D

func _ready() -> void:
	await $AnimationPlayer.animation_finished
	GameManager.change_level(load("res://Scenes/Levels/Menus/IntroScreen.tscn"))
