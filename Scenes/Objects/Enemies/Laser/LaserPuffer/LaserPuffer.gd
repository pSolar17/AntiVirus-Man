extends Enemy

# Laser Puffer enemy script

@onready
var lasers : Array[Laser] = [
	$Laser,
	$Laser2,
	$Laser3,
	$Laser4
]

@export
var base_speed : float = 90.0

@export
var direction : Vector2 = Vector2.LEFT

## Initial direction of the enemy.
@export
var initial_direction : Vector2 = Vector2.ZERO

## Laser duration.
@export
var laser_duration : float = 1.5

func _ready() -> void:
	super._ready()
	
	if initial_direction == Vector2.ZERO:
		direction = Vector2.RIGHT.rotated(3 * PI/4 + randf() * PI / 2)
	else:
		direction = initial_direction.normalized()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	velocity = direction * base_speed
	move_and_slide()
	#global_position = global_position.round()
	if get_slide_collision_count() > 0:
		var collision : KinematicCollision2D = get_slide_collision(0)
		if collision:
			# Spawn bullets...
			for laser in lasers:
				laser.lifetime = laser_duration
				laser.fire()
			# ... and bounce
			var normal = collision.get_normal()
			direction = direction.bounce(normal)
			var d : float = fposmod(direction.angle(), PI/2)
			# If we're less than 15 degrees from an axis, manually turn it up
			# This is the case when we approach an axis in counter-clockwise direction...
			if d < PI/6:
				direction = direction.rotated(PI / 12 - d)
			elif d > 5 * PI/6:
				direction = direction.rotated(-(PI/12 - d))
