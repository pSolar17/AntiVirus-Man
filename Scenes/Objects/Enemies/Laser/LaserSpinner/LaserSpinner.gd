extends Enemy

# Laser Spinner enemy script.


enum State {
	ROAM,
	SPIN
}

# Enemy parameters

## Base speed of the enemy.
@export
var base_speed : float = 60.0

## Delay before the spin attack.
@export
var pre_attack_delay : float = 1.0

## Spin attack duration.
@export
var attack_duration : float = 8.0

## If true - spins clockwise.
@export
var spin_clockwise : bool = true

@export
var positions : Array[Vector2] = [
	Vector2(256, 180),
	Vector2(384, 180),
	Vector2(512, 180),
]

## If true - inverts the order of the points.
@export
var invert_order : bool = false

## Current point this enemy will navigate to.
var point : int = 0

## Enemy's state.
var state : State = State.ROAM:
	set(value):
		state = value

func _ready() -> void:
	super._ready()
	
	$Laser1.lifetime = attack_duration
	$Laser2.lifetime = attack_duration
	$Laser1.damage *= damage_magnification
	$Laser2.damage *= damage_magnification
	if invert_order:
		positions.reverse()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if state == State.ROAM:
		if (positions.is_empty()) or (global_position == positions[point] and $DelayTimer.time_left == 0.0):
			$DelayTimer.start(pre_attack_delay)
		else:
			var d = abs(global_position.x - positions[point].x) / 64.0
			global_position = global_position.move_toward(positions[point], (.5 + d) * base_speed * delta)
	elif state == State.SPIN:
		rotation = (1 if spin_clockwise else -1) * (attack_duration - $SpinTimer.time_left) * 2 * PI / attack_duration

func _on_delay_timer_timeout() -> void:
	if state == State.ROAM:
		state = State.SPIN
		point = (point + 1) % max(positions.size(), 1)
		$Laser1.fire()
		$Laser2.fire()
		$SpinTimer.start(attack_duration)
	else:
		state = State.ROAM

func _on_spin_timer_timeout() -> void:
	$DelayTimer.start(pre_attack_delay)
	await $DelayTimer.timeout
	state = State.ROAM
