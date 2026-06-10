extends Enemy

# Carrier enemy script.

## The scene that the Carrier will spawn.
@export
var spawned_enemy_scene : PackedScene = load("res://Scenes/Objects/Enemies/Spawn/Carrier/CarrierSpawn.tscn")

## Intervals at which the Carrier will spawn the object.
@export 
var spawn_interval : float = 2.5

## The carrier's speed.
@export
var speed : float = 160.0

## The Carrier's route. It will visit these points in succession.
@export
var route : Array[Vector2] = [
	Vector2(576, 96),
	Vector2(32, 96),
	Vector2(32, 320),
	Vector2(576, 320)
]

var current_point = 0

func _ready() -> void:
	super._ready()
	$Spawner.scene = spawned_enemy_scene
	$SpawnTimer.start(spawn_interval)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	var destination = route[current_point]
	$Sprite.look_at(destination)
	global_position = global_position.move_toward(destination, speed * delta)
	if global_position.is_equal_approx(destination):
		current_point = (current_point + 1) % route.size()

func _on_spawn_timer_timeout():
	$Spawner.spawn()
