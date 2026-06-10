extends Enemy

# The Shroom enemy script.

@onready
var spawners : Array[Spawner] = [
	$Spawner,
	$Spawner2,
	$Spawner3,
	$Spawner4
]

## Max speed of the enemy.
@export
var max_speed : float = 180.0

## Deceleration of the enemy.
@export
var deceleration : float = -180.0

## Puff frequency.
@export
var period : float = 1.0

## Puff spore amount.
@export
var spore_amount : int = 1

## Spore lifetime.
@export
var spore_lifetime : float = 5.0

var current_speed : float = 0.0

func _ready() -> void:
	super._ready()
	
	$MovementTimer.start(period)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not is_instance_valid(GameManager.player):
		return
	
	current_speed = max((current_speed + deceleration * delta), 0.0)
	global_position += current_speed * Vector2.RIGHT.rotated(global_rotation) * delta

func _on_movement_timer_timeout() -> void:
	if not is_instance_valid(GameManager.player):
		return
	
	look_at(GameManager.player.global_position)
	global_rotation += 2 * (randf() - 0.5) * PI / 24
	current_speed = max_speed
	# Spawn bullets
	for spawner in spawners:
		for i in spore_amount:
			var bullet : Bullet = $Spawner.spawn()
			bullet.base_speed *= (1.0 + randf_range(-0.5, 0.5))
			bullet.acceleration = -60.0
			bullet.lifetime = spore_lifetime
			if not is_boss:
				bullet.direction = -Vector2.RIGHT.rotated(global_rotation + 2 * (randf() - 0.5) * PI/12)
			else:
				bullet.direction = -Vector2.RIGHT.rotated(global_rotation + 2 * (randf() - 0.5) * 2 * PI)
				
