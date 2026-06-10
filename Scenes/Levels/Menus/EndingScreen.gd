extends Node2D

func _ready() -> void:
	if GameManager.state.ending > -1:
		match GameManager.state.ending:
			0:
				$AnimationPlayer.play("ending1")
			1:
				$AnimationPlayer.play("ending2")
			_:
				$AnimationPlayer.play("ending3")
		
		$CanvasLayer/Control/Label2.text = "%s?" % OS.get_environment("USERNAME").to_upper()
		$CanvasLayer/Control2/Label.text = "GREETINGS, %s." % OS.get_environment("USERNAME").to_upper()
		await $AnimationPlayer.animation_finished
		GameManager.state.ending += 1
		get_tree().change_scene_to_packed(preload("res://Scenes/Levels/Menus/PresentsMenu.tscn"))
	else:
		get_tree().change_scene_to_packed(preload("res://Scenes/Levels/Menus/PresentsMenu.tscn"))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if GameManager.state.ending < 2:
			GameManager.state.ending = -1
			GameManager.state.save_to_file(GameManager.SAVE_FILE_PATH)
