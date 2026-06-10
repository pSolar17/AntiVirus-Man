class_name Laser
extends Node2D

# Laser is a special objects that creates bullets at even intervals
# 	with a time delay.

@onready
var delay_timer : Timer = $DelayTimer

## Laser's bullet scene.
@export
var bullet_scene : PackedScene = preload("res://Scenes/Objects/Bullets/Laser/LaserBullet.tscn")

## Laser length in segments.
@export
var length : int = 16

## Offset between segments in pixels.
@export
var offset : float = 16.0

## Spawn delay between segments. The first segment is always spawned immediately.
@export
var delay : float = 0.1:
	set(value):
		delay = max(value, 0.0)
		if delay_timer and delay > 0.0:
			delay_timer.wait_time = delay

## Laser lifetime. This is essentially how long the laser is fired for.
@export
var lifetime : float = 5.0

## Laser damage. Will be delegated to segments.
@export
var damage : float = 30.0

## Laser bullets at these positions will be skipped, creating a hole in the pattern.
@export
var skip_at_positions : Array[int] = []

## Laser's velocity.
@export
var velocity : Vector2 = Vector2.ZERO

var current_bullets : Array[LaserBullet] = []

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	if global_position.length() > 2048.0:
		queue_free()

func fire():
	if Engine.is_editor_hint():
		return
	
	if not bullet_scene:
		return
	
	for i in length:
		if i in skip_at_positions:
			continue
		
		var laser_bullet = bullet_scene.instantiate()
		if laser_bullet is LaserBullet:
			add_child(laser_bullet)
			laser_bullet.global_position = global_position + Vector2.RIGHT.rotated(global_rotation) * i * offset
			laser_bullet.base_damage = damage
			laser_bullet.lifetime = lifetime
		if delay > 0.0:
			delay_timer.start(delay)
			await delay_timer.timeout

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	for i in length:
		if i in skip_at_positions:
			continue
		
		draw_line((global_position + Vector2(i * offset, 0)).rotated(global_rotation),
			(global_position + Vector2((i + 1) * offset, 0)).rotated(global_rotation),
				Color.RED - Color(0.25 * (i % 4), 0.0, 0.0, 0.0), 3.0)
