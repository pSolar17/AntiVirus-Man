extends Enemy

# Carrier Spawn enemy script.

## Delay before the enemy start moving.
@export
var delay : float = 2.0

## Enemy acceleration.
@export
var acceleration : float = 640.0

var direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	$WaitTimer.start(delay)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if $WaitTimer.time_left > 0.0:
		if is_instance_valid(GameManager.player):
			look_at(GameManager.player.global_position)
	else:
		velocity += acceleration * Vector2.RIGHT.rotated(global_rotation) * delta
		move_and_slide()
