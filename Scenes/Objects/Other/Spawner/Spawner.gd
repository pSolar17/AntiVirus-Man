class_name Spawner
extends Node2D

## Spawner is a utility Node2D that spawns objects.

## Scene to be spawned.
@export
var scene : PackedScene

## NodePath to the Node that will be used as the parent. Leave blank to set as a child of the current scene.
@export
var parent : NodePath

## Position at which the object will be spawned. This is the global position if the parent is not specified.
@export
var offset : Vector2 = Vector2.ZERO

## If true - the Spawner's position is used as the starting point for the offset,
## 	as opposed to the game's origin.
@export
var use_spawner_position : bool = true

## Call this function to spawn an object.
## The return value is a reference to the newly created object.
func spawn() -> Node:
	if scene:
		if is_instance_valid(parent):
			return GameManager.spawn_packed(scene, offset, get_node(parent))
		else:
			if use_spawner_position:
				return GameManager.spawn_packed(scene, global_position + offset, null)
			else:
				return GameManager.spawn_packed(scene, offset, null)
	
	return null
