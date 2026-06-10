extends Enemy

# Sun Spike enemy script.

enum State {
	SPAWNING = 0,
	SPIN,
	ROAM,
}

## How far the spike travels after spawning.
@export
var spin_offset : float = 16.0

## How quickly the spike travels after aiming.
@export
var speed : float = 240.0

var state : State = State.SPAWNING
var initial_point : Vector2 = Vector2.ZERO

var angular_speed : float = 4 * PI

func _ready() -> void:
	super._ready()
	initial_point = global_position
	
	await $Sprite.animation_finished
	state = State.SPIN

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	match state:
		State.SPAWNING:
			return
		State.SPIN:
			var destination = initial_point + spin_offset * Vector2.RIGHT.rotated(global_rotation)
			$Sprite.rotation += angular_speed * delta
			angular_speed = max(angular_speed - delta, 2 * PI)
			global_position = global_position.lerp(destination, 2 * delta)
		State.ROAM:
			$Sprite.rotation = PI / 2
			velocity = speed * Vector2.RIGHT.rotated(global_rotation)
			move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	die()
