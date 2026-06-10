extends Node2D

func _ready() -> void:
	$AnimationPlayer.play("intro")
	await $AnimationPlayer.animation_finished
	GameManager.change_level(preload("res://Scenes/Levels/Menus/MainMenu.tscn"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Accept"):
		GameManager.change_level(preload("res://Scenes/Levels/Menus/MainMenu.tscn"))
