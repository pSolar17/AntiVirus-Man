@tool

class_name WaveObject
extends Node2D

## Object that represents a wave.
## Waves consist of enemies. These enemies are reparented to the current scene when the wave enters the tree.

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	for child in get_children():
		child.reparent(get_tree().current_scene)
	
	queue_free()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	draw_rect(Rect2(global_position - Vector2(320, 150), Vector2(640, 300)), Color(Color.RED, 0.2))
