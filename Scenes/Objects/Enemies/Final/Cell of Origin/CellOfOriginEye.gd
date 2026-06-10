extends Enemy

# Cell of Origin Eye script.

enum State {
	PHASE1,
	PHASE2,
	PHASE3
}

## Pool of enemies that can be spawned by the Cell.
@export
var spawn_pool : Array[PackedScene] = [
	preload("res://Scenes/Objects/Enemies/Spawn/Carrier/Carrier.tscn"),
	preload("res://Scenes/Objects/Enemies/Bullet/Puffer/Puffer.tscn"),
	preload("res://Scenes/Objects/Enemies/Laser/LaserPuffer/LaserPuffer.tscn"),
	preload("res://Scenes/Objects/Enemies/Final/Blue Puffer/PufferBlue.tscn"),
	preload("res://Scenes/Objects/Enemies/Bullet/The Shroom/TheShroom.tscn")
]

## Shell NodePath.
@export
var shell : Enemy

## Core NodePath.
@export
var core : Enemy

var state = State.PHASE1

var attacks : Array[Callable] = [
	attack1,
	attack2,
	attack4,
	attack5,
]

var last_attack : Callable

var t : float = 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not is_instance_valid(shell) and state == State.PHASE1:
		GameManager.boss = core
		state = State.PHASE2
		attacks.erase(attack1)
	elif not is_instance_valid(core) and state == State.PHASE2:
		GameManager.boss = self
		state = State.PHASE3
		attacks.erase(attack2)
	
	if state == State.PHASE1 or state == State.PHASE2:
		global_position = get_parent().global_position + 32 * Vector2(-1.0, global_position.direction_to(GameManager.player.global_position).y)
	elif state == State.PHASE3:
		global_position = Vector2(476, 210) + Vector2(0.0, 75 * sin(t))
		t += delta * (1.0 + 4 * current_health / max_health)

func attack1():
	$Spawner.scene = spawn_pool.pick_random()
	var enemy : Enemy = $Spawner.spawn()
	enemy.max_health = enemy.max_health / 2.0
	$Spawner2.scene = spawn_pool.pick_random()
	enemy = $Spawner2.spawn()
	enemy.max_health = enemy.max_health / 2.0
	
	$AttackTimer.start(9.0)

func attack2():
	for i in 5:
		var laser : Laser = $LaserWallSpawner.spawn()
		laser.global_rotation = PI/2
		laser.global_position = Vector2(global_position.x, 0.0)
		laser.length = 27
		laser.velocity = Vector2(-96.0 * (1.5 if state == State.PHASE2 else 1.0), 0.0)
		laser.lifetime = 20.0
		
		var skip_begin : int = randi_range(5, 16)
		if state == State.PHASE1:
			laser.skip_at_positions = [skip_begin, skip_begin + 1, skip_begin + 2, skip_begin + 3]
		elif state == State.PHASE2:
			laser.skip_at_positions = [skip_begin, skip_begin + 1, skip_begin + 2]
		
		laser.delay = 0.0
		laser.fire()
		await get_tree().create_timer(2.0).timeout
	
	$AttackTimer.start(3.0)

func attack4():
	for i in 36:
		for j in 6:
			var bullet : Bullet = $BulletSpawner.spawn()
			bullet.direction = Vector2.RIGHT.rotated(2 * PI / 5 * j + PI / 24 * i) #+ (randf_range(-1.0, 1.0) * PI/12 if state == State.PHASE3 else 0.0))
			if state == State.PHASE3:
				bullet.acceleration = 128.0
		
		await get_tree().create_timer(0.1).timeout
	
	$AttackTimer.start(3.0)

func attack5():
	for i in 32:
		var bullet : Bullet = $BulletSpawner.spawn()
		bullet.base_speed = 80.0
		if state == State.PHASE3:
			bullet.base_speed += 80.0
		
		bullet.global_position = global_position - Vector2(0.0, 64.0)
		bullet.direction = bullet.global_position.direction_to(GameManager.player.global_position)
		
		bullet = $BulletSpawner.spawn()
		bullet.base_speed = 80.0
		if state == State.PHASE3:
			bullet.base_speed += 80.0
		
		bullet.global_position = global_position + Vector2(0.0, 64.0)
		bullet.direction = bullet.global_position.direction_to(GameManager.player.global_position)
		await get_tree().create_timer(.125).timeout
	
	$AttackTimer.start(3.0)

func _on_attack_timer_timeout():
	var new_attack : Callable = attacks.pick_random()
	while new_attack == last_attack:
		new_attack = attacks.pick_random()
	last_attack = new_attack
	new_attack.call()

func die():
	GameManager.state.clears += 1
	super.die()
