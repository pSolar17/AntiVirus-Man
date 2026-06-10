extends Node2D

func _ready() -> void:
	GameManager.state.tutorial_complete = true
	
	var wave_bonus : int = GameManager.wave * 1000
	%WavesClearLabel.text = %WavesClearLabel.text % str(wave_bonus).pad_zeros(5)
	GameManager.add_score(wave_bonus)
	
	var lives_bonus : int = (GameManager.state.lives * 1000)
	%LivesScoreLabel.text = %LivesScoreLabel.text % str(lives_bonus).pad_zeros(4)
	GameManager.add_score(lives_bonus)
	
	var mission_clear_bonus : int = 25000 * (1.0 if GameManager.mission_complete else 0.0)
	%MissionClearBonusLabel.text = %MissionClearBonusLabel.text % str(mission_clear_bonus).pad_zeros(5)
	GameManager.add_score(mission_clear_bonus)
	
	# Dev gift
	GameManager.add_score(15000)
	
	%FinalScoreCountLabel.text = str(min(GameManager.state.score, 999999)).pad_zeros(6)
	
	if GameManager.state.score < GameManager.state.high_score:
		%NewBestLabel.text = ""
	
	GameManager.score_multiplier = 1.0

func _input(event: InputEvent) -> void:
	if $AnimationPlayer.is_playing():
		return
	
	if event.is_action_pressed("Accept"):
		if GameManager.wave == GameManager.MISSION_WAVE_COUNT and GameManager.state.ending != -1:
			GameManager.change_level(load("res://Scenes/Levels/Menus/EndingScreen.tscn"))
		else:
			GameManager.change_level(load("res://Scenes/Levels/Menus/StrainMenu.tscn"))
