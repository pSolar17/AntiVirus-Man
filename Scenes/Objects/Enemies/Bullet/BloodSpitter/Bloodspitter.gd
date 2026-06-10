extends Enemy

# Bloodspitter enemy script.

enum State {
	APPROACH,
	CIRCLE
}

## Base speed. Mainly used when approaching the player.
@export
var base_speed : float = 360.0

## Object that the enemy will try to circle. Leave at null to target the player.
@export
var spin_target : Node2D = null

## The amount of time it takes the enemy to cycle around the player.
@export
var spin_interval : float = 6.0

## The radius at which the enemy spins.
@export
var spin_radius : float = 160.0

## Spin offset.
@export
var spin_offset : float = 0.0

## Bullet spawn interval.
@export
var shot_interval : float = 3.0

## Bullet velocity.
@export
var bullet_speed : float = 64.0

## Randomization factor of shooting.
## Spawn interval will fluctuate between (1.0 - factor) * shot_interval and (1.0 + factor) * shot_interval
@export
var shot_interval_rfactor : float = 0.5

var state : State = State.APPROACH

func _ready() -> void:
	super._ready()
	
	$CircleTimer.start(spin_interval)
	$ShotTimer.timeout.connect(_on_shot_timer_timeout)
	$ShotTimer.start(shot_interval * (1.0 + randf_range(-shot_interval_rfactor, shot_interval_rfactor)))

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not is_instance_valid(spin_target):
		spin_target = GameManager.player
	# If no player spotted - do nothing
	if not is_instance_valid(GameManager.player):
		return
	
	$Sprite.look_at(spin_target.global_position)
	# Get next point to travel to
	var angle = 2 * PI * ($CircleTimer.time_left - spin_offset) / $CircleTimer.wait_time
	var destination : Vector2 = spin_target.global_position + spin_radius * Vector2(cos(angle), sin(angle))
	if state == State.CIRCLE and global_position.distance_to(destination) > 32.0:
		state = State.APPROACH
	elif state == State.APPROACH and global_position.distance_to(destination) < 32.0:
		state = State.CIRCLE
	
	if state == State.APPROACH:
		global_position = global_position.move_toward(destination, base_speed * delta)
	elif state == State.CIRCLE:
		global_position = destination

func _on_shot_timer_timeout():
	if not is_instance_valid(GameManager.player):
		return
	
	# Check distance, don't shoot if too close to the player
	var distance : float = global_position.distance_to(GameManager.player.global_position)
	if distance < 0.75 * spin_radius:
		return
	
	var bullet : Node = $Spawner.spawn()
	if bullet is not Bullet:
		bullet.queue_free()
	elif bullet is Bullet:
		bullet.direction = global_position.direction_to(GameManager.player.global_position)
		bullet.base_speed = bullet_speed
	
	$ShotTimer.start(shot_interval * (1.0 + randf_range(-shot_interval_rfactor, shot_interval_rfactor)))
