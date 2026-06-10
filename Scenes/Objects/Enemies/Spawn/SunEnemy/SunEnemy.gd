extends Enemy

# Sun Enemy script.

enum State {
	ROAM,
	SPAWN
}

## Base speed of the enemy.
@export
var base_speed : float = 90.0

## The amount of spikes on this Sun.
@export
var spike_count : int = 8

## Delay before the spikes are shot.
@export
var shot_delay : float = .5

## The delay between spike shots.
@export
var shot_interval : float = 0.125

## Spawner offset.
@export
var spawner_offset : float = 32.0

## The distance that spikes travel when spinning.
@export
var spike_distance : float = 16.0

var destination : Vector2 = Vector2(320, 240)
var spikes : Array = []
var state : State = State.SPAWN:
	set(value):
		state = value
		if state == State.ROAM:
			if not is_instance_valid(GameManager.player):
				return
			# Pick a new point to move into.
			# It must satisfy the following conditions(the higher the condition, the higher its priority):
			# It will be a point within the level boundary,
			# 	behind the player,
			# 	at least 64 pixels away from the player.
			destination = GameManager.player.global_position
			var offset : Vector2 = randi_range(64, 128) * Vector2.RIGHT.rotated(global_position.direction_to(GameManager.player.global_position).angle())
			destination = (destination + offset).clamp(Vector2(64, 144), Vector2(576, 296))

func _ready() -> void:
	super._ready()
	
	state = State.ROAM

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if state == State.ROAM:
		var d = abs(global_position.x - destination.x) / 64.0
		global_position = global_position.move_toward(destination, (.5 + d) * base_speed * delta)
		if global_position.is_equal_approx(destination):
			state = State.SPAWN
			attack()

# Spawns the spikes and shoots them
func attack():
	spikes = []
	for i in spike_count:
		var angle : float = 2 * PI * i / spike_count
		$Spawner.global_position = global_position + spawner_offset * Vector2.RIGHT.rotated(angle)
		var spike = $Spawner.spawn()
		spike.spin_offset = spike_distance
		spikes.push_back(spike)
		spike.rotation = angle
	
	$ShotTimer.start(1.5 + shot_delay)
	await $ShotTimer.timeout
	for spike in spikes:
		$ShotTimer.start(shot_interval)
		await $ShotTimer.timeout
		spike.state = 2
		spike.look_at(GameManager.player.global_position)
	state = State.ROAM

func die():
	for spike in spikes:
		if is_instance_valid(spike):
			spike.die()
	
	super.die()
