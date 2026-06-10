extends Enemy

# Puffer enemy script

@export
var base_speed : float = 60.0

@export
var direction : Vector2 = Vector2.LEFT

## Initial direction of the enemy.
@export
var initial_direction : Vector2 = Vector2.ZERO

@export
var bullet_scene : PackedScene = preload("res://Scenes/Objects/Bullets/EnemyBullet.tscn")

@export
var bullet_count : int = 10

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
			for i in bullet_count:
				var bullet = bullet_scene.instantiate()
				if bullet is Bullet:
					get_tree().get_current_scene().add_child(bullet)
					bullet.global_position = global_position
					bullet.base_speed = 60.0
					bullet.direction = Vector2.RIGHT.rotated(2 * PI * i / bullet_count)
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
