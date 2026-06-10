extends Enemy

# Tutorial Boss script.

## Horizontal speed of the enemy.
@export
var h_speed : float = 120.0

## Enemy's current horizontal direction.
@export
var h_direction : float = -1.0

## Enemy bounce velocity.
@export
var bounce_velocity : float = 360.0

## Enemy gravity.
@export
var gravity : float = 360.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Rotate the sprite
	$Sprite.rotation -= PI / 3 * delta
	
	velocity.x = h_speed * h_direction
	# Calculate current y velocity.
	velocity.y += gravity * delta
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		var collision : KinematicCollision2D = get_slide_collision(0)
		if collision:
			# If colliding with something below, bounce.
			if collision.get_normal() == Vector2.UP:
				velocity.y = -bounce_velocity
			# If colliding at a side
			elif is_zero_approx(collision.get_normal().y):
				h_direction *= -1.0

func _on_timer_timeout():
	$CanvasLayer.hide()

func die():
	GameManager.state.tutorial_complete = true
	
	super.die()
