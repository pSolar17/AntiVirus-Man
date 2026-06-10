extends Enemy

# Laser enemy script

## Base speed of the enemy.
@export
var base_speed : float = 120.0

## Initial direction of the enemy.
@export
var direction : Vector2 = Vector2.DOWN

## Attack frequency.
@export
var attack_interval : float = 3.0

## Attack duration. Best set at something higher than 24 frames(the time it takes to play laser anim).
@export
var attack_duration : float = 1.0

## Attack offset.
@export
var attack_offset : float = 0.0

## Desired X position for the enemy.
@export
var desired_x : float = 560.0

func _ready() -> void:
	super._ready()
	
	$AttackTimer.start(attack_interval - attack_offset)
	$Laser.lifetime = attack_duration
	$Laser.damage *= damage_magnification

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if global_position.x > desired_x:
		velocity.x = 120.0 * sign(desired_x - global_position.x)
	else:
		velocity = direction * base_speed
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		var collision : KinematicCollision2D = get_slide_collision(0)
		if collision:
			direction = direction.rotated(PI)

func _on_attack_timer_timeout() -> void:
	if $VisibleOnScreenNotifier2D.is_on_screen():
		$Laser.fire()
	$AttackTimer.start(attack_interval)
