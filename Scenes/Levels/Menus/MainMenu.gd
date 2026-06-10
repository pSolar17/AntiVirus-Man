extends Node2D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Accept"):
		$AudioStreamPlayer.stop()
		$AcceptSound.play()
		await $AcceptSound.finished
		if GameManager.state.tutorial_complete:
			GameManager.change_level(load("res://Scenes/Levels/Menus/StrainMenu.tscn"))
		else:
			GameManager.change_level(load("res://Scenes/Levels/Test/TutorialLevel.tscn"))
