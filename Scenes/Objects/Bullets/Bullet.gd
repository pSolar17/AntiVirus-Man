class_name Bullet
extends Node2D

## Base class for all bullets.

## Bullet's owner. Should be set by whatever spawns it.
@export
var bullet_owner : Node

## Bullet's base speed.
@export
var base_speed : float = 120.0

## Bullet's base acceleration.
@export
var acceleration : float = 0.0

## Bullet's direction
@export
var direction : Vector2 = Vector2.RIGHT

## Bullet's base damage.
@export
var base_damage : float = 20.0


@export
var lifetime : float = 16.0:
	set(value):
		lifetime = max(value, 1.0/60.0)
		$LifeTimer.start(lifetime)

## If true - friendly fire enabled for this bullet.
## Bullets still won't damage their owner.
@export
var friendly_fire : bool = false

## If true - the bullet is active.
var active : bool = true

func _ready() -> void:
	$LifeTimer.start(lifetime)

func _physics_process(delta: float) -> void:
	if not active:
		return
	# Movement
	global_position += direction * base_speed * delta
	base_speed += acceleration * delta
	base_speed = max(base_speed, 0.0)
	#global_position = global_position.round()
	
	# Damage everything underneath itself
	for body in $Area2D.get_overlapping_bodies():
		if body != bullet_owner:
			if body is Enemy and friendly_fire:
				body.take_damage(base_damage)
			elif body is Player:
				body.take_damage(base_damage)
			if body is Enemy and body.max_health > self.base_damage:
				destroy()
	
	if $LifeTimer.time_left == 0.0:
		destroy()
	
	# If for some reason the bullet strayed far away - destroy it.
	if global_position.length() > 2048.0:
		destroy()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destroy()

func destroy():
	queue_free()
