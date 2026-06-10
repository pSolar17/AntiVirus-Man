extends Enemy

# Pipe Enemy script.

enum State {
	SPAWN,
	ROAM
}

const H_SPEED : float = 120.0

## Initial direction.
@export
var direction : Vector2 = Vector2.UP

## Spawn count.
@export
var spawn_count : int = 5

## Interval between individual spawns.
@export
var spawn_delay : float = 0.2

## Interval between batches.
@export
var spawn_interval : float = 1.5

## Interval offset.
@export
var interval_offset : float = 0.0

## Vertical speed.
@export
var v_speed : float = 120.0

var state : State = State.ROAM
var desired_x_reached : bool = false
var spawned_count : int = 0

var DESIRED_X : float = 623.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if is_boss:
		DESIRED_X = 640.0 - 49.0
	if not desired_x_reached:
		global_position = global_position.move_toward(Vector2(DESIRED_X, global_position.y), H_SPEED * delta)
		if is_equal_approx(global_position.x, DESIRED_X):
			desired_x_reached = true
			$BatchTimer.start(max(spawn_interval - interval_offset, 4.0 / 60.0))
	else:
		if state == State.ROAM:
			velocity = v_speed * direction
			move_and_slide()
			if get_slide_collision_count() > 0:
				var collision : KinematicCollision2D = get_slide_collision(0)
				if collision:
					direction = direction.rotated(PI)

func _on_batch_timer_timeout():
	state = State.SPAWN
	for i in spawn_count:
		var spawned_enemy : Enemy = $Spawner.spawn()
		if is_boss:
			spawned_enemy.amplitude *= randf_range(0.75, 2.25)
		spawned_enemy.bounty = max(spawned_enemy.bounty - spawned_count * 10, 0)
		$DelayTimer.start(spawn_delay)
		await $DelayTimer.timeout
	spawned_count += 1
	state = State.ROAM
	$BatchTimer.start(spawn_interval)
