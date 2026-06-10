extends Enemy

# The Shield enemy script.

## Object that the enemy will circle.
@export
var spin_target : Node2D = null

## The amount of time it takes the enemy to cycle around the target.
@export
var spin_interval : float = 6.0

## The radius at which the enemy spins.
@export
var spin_radius : float = 160.0

## Spin offset.
@export
var spin_offset : float = 0.0

## Bullet velocity.
@export
var bullet_speed : float = 64.0

## Shot count.
@export
var bullet_count : int = 5

func _ready() -> void:
	super._ready()
	
	$CircleTimer.start(spin_interval)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not is_instance_valid(spin_target):
		die()
		return
	
	$Sprite.look_at(spin_target.global_position)
	# Get next point to travel to
	var angle = 2 * PI * ($CircleTimer.time_left - spin_offset) / $CircleTimer.wait_time
	global_position = spin_target.global_position + spin_radius * Vector2.RIGHT.rotated(angle)

func take_damage(value : float):
	# Shoot back at the player.
	if is_instance_valid(GameManager.player):
		for i in bullet_count:
			var bullet : Bullet = $Spawner.spawn()
			bullet.direction = global_position.direction_to(GameManager.player.global_position).rotated(randf_range(-1.0, 1.0) * PI/12)
			bullet.base_speed *= randf_range(0.75, 3.0)
			bullet.base_damage = value
	
	super.take_damage(value)
