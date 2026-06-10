class_name MissionLevel
extends Node2D

## Mission level script.

var no_hit : bool = true

## This level's sections.
@export
var sections : Array[String] = ["bullet", "laser", "spawn"]

## This level's wave count.
@export
var wave_count : int = GameManager.MISSION_WAVE_COUNT

## Tutorial level flag.
@export
var tutorial : bool = false

## Level's waves.
@export
var waves : Array = []
	
func _ready() -> void:
	GameManager.state.score = 0
	GameManager.boss = null
	GameManager.wave_killed.connect(_on_wave_killed)
	GameManager.wave = -1
	GameManager.mission_complete = false
	
	$Player.hurt.connect(_on_player_hurt)
	await $AnimationPlayer.animation_finished
	%StatusLabel.text = "ENEMIES INBOUND!"

func _process(delta: float) -> void:
	_update_ui()

func _update_ui():
	if GameManager.player:
		%HealthCounterLabel.text = str(int(GameManager.player.current_health)).pad_zeros(3)
		%LivesCounterLabel.text = str(int(GameManager.state.lives)).pad_zeros(3)
	%ScoreCounterLabel.text = str(min(GameManager.state.score, 999999)).pad_zeros(6)
	%BestCounterLabel.text = str(min(GameManager.state.high_score, 999999)).pad_zeros(6)
	if is_instance_valid(GameManager.boss):
		%BossHealthBar.max_value = GameManager.boss.max_health
		%BossHealthBar.value = GameManager.boss.current_health
		%BossHealthBar.visible = true
		%BossHealthLabel.visible = true
	else:
		%BossHealthBar.visible = false
		%BossHealthLabel.visible = false
		
	%WaveCounterLabel.text = "%s OF %s" % [str(min(GameManager.wave + 1, wave_count)).pad_zeros(2), str(wave_count).pad_zeros(2)]

func _on_wave_killed():
	print("Wave killed")
	$WaveTimer.start(GameManager.DELAY_BETWEEN_WAVES * (2.0 if GameManager.wave % 5 == 4 else 1.0))
	if no_hit:
		%StatusLabel.text = "NO HIT! +1000 PTS"
		GameManager.state.score += 1000
		await get_tree().create_timer(GameManager.DELAY_BETWEEN_WAVES / 2.0).timeout
	var time_bonus = get_time_bonus($WaveClearTimer.time_left, $WaveClearTimer.wait_time, 200 * (GameManager.wave + 1))
	if time_bonus > 0:
		GameManager.state.score += time_bonus
		%StatusLabel.text = "TIME BONUS +%d PTS" % time_bonus
	else:
		%StatusLabel.text = "WAVE CLEAR!"

func _on_wave_timer_timeout() -> void:
	if GameManager.wave < wave_count:
		no_hit = true
		%StatusLabel.text = ""
		GameManager.wave += 1
		if GameManager.wave == wave_count:
			GameManager.mission_complete = true
			GameManager.change_level(load("res://Scenes/Levels/Menus/MissionClearScreen.tscn"))
			return
		
		# If waves are empty, get new ones from the WaveManager
		if waves.is_empty():
			if sections.is_empty():
				sections.append("final")
			sections.shuffle()
			var section = sections.pop_front()
			waves = WaveManager.get_wave_data_for_section(section)
		$WaveSpawner.scene = waves.pop_front()
		$WaveSpawner.spawn()
		#
		var wave_time = 20.0 + 4.0 * GameManager.wave * (2.0 if GameManager.wave % 10 == 4 else 1.0)
		$WaveClearTimer.wait_time = wave_time
		$WaveClearTimer.start(wave_time)
		# Update music
		if GameManager.wave == 19:
			$AudioStreamPlayer.stream = load("res://Assets/Audio/Music/FinalBoss.mp3")
			$AudioStreamPlayer.play()
		elif GameManager.wave % 5 == 4:
			$AudioStreamPlayer.stream = load("res://Assets/Audio/Music/Boss1.mp3")
			$AudioStreamPlayer.play()
		elif GameManager.wave % 5 == 0 and GameManager.wave > 14:
			$AudioStreamPlayer.stream = load("res://Assets/Audio/Music/FinalStage.mp3")
			$AudioStreamPlayer.play()
		elif GameManager.wave % 5 == 0 and GameManager.wave != 0:
			$AudioStreamPlayer.stream = load("res://Assets/Audio/Music/Level1(tmp).mp3")
			$AudioStreamPlayer.play()

func _on_player_hurt(value : float):
	no_hit = false

func get_time_bonus(time_left : float, total_time : float, max_bonus : int) -> int:
	if time_left > total_time / 2.0:
		return max_bonus
	else:
		var d = (total_time - 2 * time_left) / total_time
		return int((1.0 - d) * max_bonus)
