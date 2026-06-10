extends Enemy

# Splitter Cell enemy script.

## Split count.
@export
var split_count : int = 1

## Max velocity amplitude.
@export
var max_velocity : float = 120.0

## Acceleration amplitude.
@export
var acceleration : float = 240.0

# Random offset so that the cells don't stack in one point. Rolled on spawn.
var offset : Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	
	if not is_boss:
		offset = Vector2(8 - randi() % 17, 8 - randi() % 17)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Get player
	var player = GameManager.player
	if not player:
		return
	else:
		# Home in on player with delay.
		# Instead of setting velocity directly to direction_to(player) * max_velocity,
		# 	accelerate towards player.
		var destination = player.global_position + offset
		var desired_velocity = global_position.direction_to(GameManager.player.global_position) * max_velocity
		$Sprite.look_at(destination)
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
		velocity = velocity.limit_length(max_velocity)
		move_and_slide()
		if get_slide_collision_count() > 0:
			var collision : KinematicCollision2D = get_slide_collision(0)
			if collision:
				#velocity = velocity.rotated(PI)
				pass

func die():
	if self.split_count > 0:
		for i in 2:
			var new_cell : Enemy = GameManager.spawn_copy(self, global_position + 32 * (-1.0 if i else 1.0) * Vector2.RIGHT.rotated(velocity.angle()))
			if new_cell:
				new_cell.split_count -= 1
				new_cell.velocity = velocity.rotated(PI / 2 * (-1.0 if i % 2 == 0 else 1.0))
				if is_boss:
					new_cell.max_velocity *= 1.5
				new_cell.max_health = self.max_health / 2.0
				new_cell.bounty = int(self.bounty / 2.0)
				new_cell.rna_bounty = int(self.rna_bounty / 2.0)
				new_cell.dna_bounty = 0
				new_cell.scale.x = max(self.scale.x / 2.0, 0.125)
				new_cell.scale.y = max(self.scale.y / 2.0, 0.125)
				# Make the material unique as well so the children don't get synced damage animations
				new_cell.get_node("Sprite").material = get_node("Sprite").material.duplicate()
	super.die()
	
