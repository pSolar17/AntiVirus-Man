extends Node

# Global Node that manages the game.

signal wave_killed

const DELAY_BETWEEN_WAVES : float = 5.0
const MAGNIFICATION_PER_WAVE : float = 0.025
const MAGNIFICATION_PER_CLEAR : float = 0.3
const MISSION_WAVE_COUNT : int = 20
const MAX_STRAINS : int = 5
const SAVE_FILE_PATH : String = "user://save_notdemo.2ch"

@onready
var animation_player : AnimationPlayer = $AnimationPlayer

## Current game state.
@export
var state : GameState = GameState.new()

## Current player.
var player : Player = null

## Current enemies. Meant to be interacted with via register_enemy.
var enemies : Array[Enemy] = []

## Current boss.
var boss : Enemy = null

## Current wave.
var wave : int = -1

## Mission completion flag.
var mission_complete : bool = false

## Score multiplier. Reset to 1.0 after each mission.
var score_multiplier : float = 1.0:
	set(value):
		score_multiplier = max(value, 0.0)

func scr_fade_in():
	animation_player.play("fade_in")

func scr_fade_out():
	animation_player.play("fade_out")

func change_level(level : PackedScene):
	get_tree().paused = true
	
	scr_fade_out()
	await $AnimationPlayer.animation_finished
	
	get_tree().change_scene_to_packed(level)
	
	scr_fade_in()
	await $AnimationPlayer.animation_finished
	
	get_tree().paused = false

func _ready() -> void:
	#change_level(preload("res://Scenes/Levels/Test/TestLevel.tscn"))
	state.read_from_file(SAVE_FILE_PATH)
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	scr_fade_in()

func _physics_process(delta: float) -> void:
	for enemy in enemies:
		if not is_instance_valid(enemy):
			enemies.erase(enemy)
	pass

func register_enemy(enemy : Enemy):
	if not enemy in enemies:
		enemies.append(enemy)
		enemy.killed.connect(_on_enemy_killed)
	
	if enemy.is_boss:
		boss = enemy

func _on_enemy_killed(enemy : Enemy):
	enemies.erase(enemy)
	if enemies.is_empty():
		wave_killed.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Close"):
		quit()
	elif event.is_action_pressed("Debug"):
		state.clears = 0
		pass
	if event.is_action_pressed("Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if event.is_action_pressed("CRT"):
		$CanvasLayer/ShaderRect.visible = !$CanvasLayer/ShaderRect.visible
	elif event.is_action_pressed("VolumeUp"):
		AudioServer.set_bus_volume_linear(0, min(AudioServer.get_bus_volume_linear(0) + 0.1, 1.0))
	elif event.is_action_pressed("VolumeDown"):
		AudioServer.set_bus_volume_linear(0, max(AudioServer.get_bus_volume_linear(0) - 0.1, 0.0))
	elif event.is_action_pressed("VolumeRestore"):
		AudioServer.set_bus_volume_linear(0, 1.0)
	elif event.is_action_pressed("VolumeMute"):
		if AudioServer.get_bus_volume_linear(0) == 0.0:
			AudioServer.set_bus_volume_linear(0, 1.0)
		else:
			AudioServer.set_bus_volume_linear(0, 0.0)


func quit():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		state.save_to_file(SAVE_FILE_PATH)

## Instances the scene at desired coordinates.
## If parent is null or invalid, 'where' is global coordinates and the object is added as a child of the current scene.
## If parent is valid, 'where' is local coordinates and the object is added as a child of this node.
## Returns a reference to the spawned object, or null if the function failed.
func spawn_packed(scene : PackedScene, where : Vector2 = Vector2.ZERO, parent : Node = null) -> Node:
	if scene:
		var object : Node = scene.instantiate()
		if is_instance_valid(parent):
			if object is Node2D:
				object.position = where
			parent.add_child(object)
			return object
		else:
			if object is Node2D:
				object.global_position = where
			get_tree().current_scene.add_child(object)
			return object
	
	return null

## Spawns a copy of the given Node2D and places it at given global coordinates as a child of the current scene.
func spawn_copy(node : Node2D, where : Vector2 = Vector2.ZERO) -> Node2D:
	if is_instance_valid(node):
		var copy : Node2D = node.duplicate()
		copy.global_position = where
		get_tree().current_scene.add_child(copy)
		return copy
	return null

func delete_save_data():
	DirAccess.remove_absolute(SAVE_FILE_PATH)
	state = GameState.new()

## Adds the value to the score.
func add_score(value : int):
	if state:
		state.score += value * score_multiplier

## Adds the RNA.
func add_rna(value : int):
	if state:
		state.rna += value

func add_dna(value : int):
	if state:
		state.dna += value
