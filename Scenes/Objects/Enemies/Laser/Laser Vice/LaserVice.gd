class_name LaserVice
extends Enemy

# Laser Vice enemy script.

# Playing field height in laser segments.
# We don't want to spawn lasers of that height or higher because they can't be dodged.
# Ideally, they should be 10-12 in length at max.
const FIELD_HEIGHT_SEGMENTS : int = 19

## The part that will act with this one.
## If this part does not have a counterpart, it will still act alone.
## If you specify a part that also has a pair specified, they will be randomly redistributed.
@export
var pair : LaserVice = null

## Upper part flag.
@export
var upper : bool = true:
	set(value):
		upper = value
		if upper:
			$Sprite.rotation = 0.0
			$Spawner.position.y = 4.0
		else:
			$Sprite.rotation = PI
			$Spawner.position.y = -4.0

## Min laser wall length in segments.
@export
var laser_length_min : int = 4

## Max laser wall length in segments.
@export
var laser_length_max : int = 12

## Attack interval. This is floored at 1.0 seconds so the parts can reach their places.
@export
var attack_interval : float = 1.0:
	set(value):
		attack_interval = max(value, 1.0)

## Attack offset.
@export
var attack_offset : float = 0.0

## Delay before moving on to the next attack.
@export
var post_attack_delay : float = 1.0

## Laser's velocity.
@export
var laser_velocity : Vector2 = Vector2(-90.0, 0.0)

## Laser damage.
@export
var laser_damage : float = 30.0

## Desired X. This will be overridden by the upper part.
@export
var desired_x : float = 576.0

var length_this_attack : int = 0
var destination : Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	
	if not upper and is_instance_valid(pair):
		if pair.pair != self:
			self.pair = null
	# Fix potential inconsistencies
	if upper and is_instance_valid(pair):
		pair.upper = false
		pair.pair = self
		pair.desired_x = self.desired_x
		pair.attack_interval = self.attack_interval
		pair.attack_offset = self.attack_offset
		pair.laser_damage = self.laser_damage
		pair.laser_velocity = self.laser_velocity

	
	think()
	$AttackTimer.start(attack_interval - attack_offset)

func _physics_process(delta: float) -> void:
	# Move to our destination
	global_position = global_position.lerp(destination, 0.2)

func _on_attack_timer_timeout():
	# Fire the laser
	if upper or not is_instance_valid(pair):
		var laser : Laser = $Spawner.spawn()
		laser.delay = 0.0
		laser.rotation = (PI / 2 if upper else - PI / 2)
		laser.velocity = laser_velocity
		laser.damage = laser_damage
		laser.length = length_this_attack
		laser.lifetime = 16.0
		laser.fire()
	$DelayTimer.start(post_attack_delay)
	await $DelayTimer.timeout
	think()

func think():
	if upper:
		# Get a new point above the field middle line.
		# If we don't have a pair, we have to make sure it has some space for player to dodge.
		destination = Vector2(desired_x, 70.0)
		# Choose a random offset so our destination lands in the [80, 200] interval.
		# 200 is chosen as the upper limit because that's the highest y where the enemy is still in the upper half.
		
		if is_instance_valid(pair):
			# If we're still paired, there should be plenty of space for player to dodge.
			destination.y += randi_range(0, 130)
		else:
			# If we're alone, add some space for player to dodge while still being annoying.
			destination.y += randi_range(30, 130)
		# Next, we roll the laser's length.
		# If we're the only part left, set it to field height in segments. This will guarantee the laser will stretch to the edge.
		if not is_instance_valid(pair):
			length_this_attack = FIELD_HEIGHT_SEGMENTS
		# Otherwise...
		# It can't be higher than the max length, and it also should allow the lower part to be seen.
		# First, calculate how many segments we can still fit in.
		else:
			var available_space : float = 360.0 - destination.y - 10.0 # -10 to fit the lower part in
			var max_segments : int = floor(available_space / 16.0)
			length_this_attack = randi_range(laser_length_min, min(max_segments, laser_length_max))
			# Now that we rolled the length of the attack, we can delegate the new destination to our pair.
			pair.destination = destination + 16 * Vector2(0.0, length_this_attack)
	elif not is_instance_valid(pair):
		# If we're not the upper part and our pair
		# It's mostly the same as the upper, but the destination calculation is a bit different.
		destination = Vector2(desired_x, 350.0)
		destination -= Vector2(0, randi_range(30, 130))
		# Since we only reach this code if we're a lower part that lost it's higher part, our laser length will always be max.
		length_this_attack = FIELD_HEIGHT_SEGMENTS
	$AttackTimer.start(attack_interval)
