extends Enemy

# Coin Flipper enemy script.

## Amplitude of movement in pixels.
@export
var amplitude : float = 40.0

## Period of movement. This is the time after which the enemy completes the full cycle of sine wave.
## In short, shorter period - the enemy will oscillate faster.
@export
var period : float = 1.0

## Horizontal velocity.
@export
var speed : float = 120.0

var initial_point : Vector2 = Vector2.ZERO
var t : float = 0.0

func _ready() -> void:
	super._ready()
	initial_point = self.global_position

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Calculate my position
	# Since the enemy is intended to move left, we subtract delta.
	t -= delta
	
	global_position = initial_point + Vector2(speed * t, amplitude * sin(2 * PI * t / period))

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	die()
