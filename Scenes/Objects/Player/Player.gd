class_name Player
extends CharacterBody2D

# --- Signals ---#

signal hurt(value : float)

#--- Constants ---#

const BASE_IFRAMES_ON_HIT : int = 180

#--- Variables ---#

## Player's bullet scene.
@export
var bullet_scene : PackedScene = preload("res://Scenes/Objects/Bullets/PlayerBullet.tscn")

@export
var can_attack : bool = true

@export
var can_move : bool = true


## Player's current health.
var current_health : float:
	set(value):
		current_health = clamp(value, 0.0, stats.max_health)
		if is_zero_approx(current_health):
			handle_zero_health()

## Player's i-frames.
var iframes : int = 0

## Player's base stats.
@export
var base_stats : Dictionary = {
	# Base stats. Usually not modified.
	"speed" : 120.0,
	"damage_mult" : 1.0,
	"lives" : 3,
	"max_health" : 99.0,
	"iframes" : 180,
	"fire_rate" : 2.5,
	"bullet_size" : 1.0,
}


## Player's current stats.
@export
var stats : Dictionary = {
	# Final stats. These are usually modified by bonuses.
	"speed" : 120.0,
	"damage_mult" : 1.0,
	"max_health" : 99.0,
	"health_regen" : 0.0,
	"iframes" : 180,
	"fire_rate" : 2.5,
	"damage_reduction" : 0.0,
	"bullet_size" : 1.0,
}

func _ready() -> void:
	GameManager.player = self
	apply_bonuses()
	
	# Set stats
	$AttackTimer.wait_time = max(1.0 / stats.fire_rate, 0.05)
	current_health = floor(stats.max_health)
	GameManager.state.lives = max(floor(base_stats.lives), 0)

func _physics_process(delta: float) -> void:
	# Movement
	var direction : Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	if not can_move:
		direction = Vector2.ZERO
	velocity = direction * stats.speed
	move_and_slide()
	#global_position = global_position.round()
	
	# Tick i-frames
	if iframes > 0:
		iframes -= 1
	
	# Invincibility animation
	if iframes != 0 and iframes % 30 < 15:
		$Sprite.material.set_shader_parameter("enabled", false)
	elif iframes != 0 and iframes % 30 >= 15:
		$Sprite.material.set_shader_parameter("enabled", true)
	
	# Attacking
	if Input.is_action_pressed("Attack") and can_attack:
		if $AttackTimer.time_left == 0.0:
			var bullet : Node = bullet_scene.instantiate()
			if bullet is Bullet:
				bullet.bullet_owner = self
				bullet.scale *= stats.bullet_size
				bullet.global_position = $BulletSpawnPoint.global_position
				bullet.base_damage = bullet.base_damage * stats.damage_mult
				bullet.base_speed = 360.0
				get_tree().get_current_scene().add_child(bullet)
				$AttackTimer.start()
				$ShootSound.play()
			else:
				bullet.queue_free()
	
	# Health regen
	if current_health != 0.0:
		current_health += stats.health_regen * delta

func take_damage(value : float):
	if iframes > 0:
		return
	if current_health == 0.0:
		return
	
	# Amplify before applying
	value = value * (1.0 + GameManager.MAGNIFICATION_PER_WAVE * GameManager.wave + GameManager.MAGNIFICATION_PER_CLEAR * GameManager.state.clears)
	# Reduce
	value = value * (1.0 - stats.damage_reduction)
	
	print("Player taking %.2f damage!" % value)
	iframes = max(stats.iframes, 20)
	current_health -= value
	hurt.emit(value)
	$HitSound.play()

## Applies bonuses from strains currently loaded in state.
func apply_bonuses():
	# Reset any stats just in case I changed base values and forgot about that.
	for stat in base_stats:
		if stat in stats:
			stats[stat] = base_stats[stat]
	
	for strain in GameManager.state.strains:
		if not strain:
			continue
		
		# Apply positive effect
		match strain.positive_effect:
			Strain.EffectType.DAMAGE:
				stats.damage_mult += strain.get_positive_effect_value() / 100.0
			Strain.EffectType.FIRE_RATE:
				stats.fire_rate += base_stats.fire_rate * strain.get_positive_effect_value() / 100.0
			Strain.EffectType.SPEED:
				stats.speed += base_stats.speed * strain.get_positive_effect_value() / 100.0
			Strain.EffectType.HEALTH:
				stats.max_health += strain.get_positive_effect_value()
			Strain.EffectType.LIVES:
				base_stats.lives += strain.get_positive_effect_value()
			Strain.EffectType.DAMAGE_RESISTANCE:
				stats.damage_reduction += strain.get_positive_effect_value() / 100.0
			Strain.EffectType.IFRAMES:
				stats.iframes += base_stats.iframes * strain.get_positive_effect_value() / 100.0
			Strain.EffectType.HEALTH_REGEN:
				stats.health_regen += strain.get_positive_effect_value()
			Strain.EffectType.SCORE:
				GameManager.score_multiplier += strain.get_positive_effect_value() / 100.0
			Strain.EffectType.BULLET_SIZE:
				stats.bullet_size += strain.get_positive_effect_value() / 100.0
		
		# Apply negative effect
		match strain.negative_effect:
			Strain.EffectType.DAMAGE:
				stats.damage_mult -= strain.get_negative_effect_value() / 100.0
			Strain.EffectType.FIRE_RATE:
				stats.fire_rate -= base_stats.fire_rate * strain.get_negative_effect_value() / 100.0
			Strain.EffectType.SPEED:
				stats.speed -= base_stats.speed * strain.get_negative_effect_value() / 100.0
			Strain.EffectType.HEALTH:
				stats.max_health -= strain.get_negative_effect_value()
			Strain.EffectType.LIVES:
				base_stats.lives -= strain.get_negative_effect_value()
			Strain.EffectType.DAMAGE_RESISTANCE:
				stats.damage_reduction -= strain.get_negative_effect_value() / 100.0
			Strain.EffectType.IFRAMES:
				stats.iframes -= base_stats.iframes * strain.get_negative_effect_value() / 100.0
			Strain.EffectType.HEALTH_REGEN:
				stats.health_regen -= strain.get_negative_effect_value()
			Strain.EffectType.SCORE:
				GameManager.score_multiplier -= strain.get_negative_effect_value() / 100.0
			Strain.EffectType.BULLET_SIZE:
				stats.bullet_size -= strain.get_negative_effect_value() / 100.0

func handle_zero_health():
	if GameManager.state.lives > 0:
		GameManager.state.lives -= 1
		current_health = floor(stats.max_health)
		iframes = 2 * max(stats.iframes, 20)
	else:
		hide()
		can_attack = false
		can_move = false
		for i in 8:
			var explosion : Node2D = GameManager.spawn_packed(preload("res://Scenes/Objects/Other/ExplosionObject.tscn"), global_position + Vector2(randi() % 49 - 24, randi() % 49 - 24))
			explosion.scale *= randf_range(1.0, 2.0)
			await get_tree().create_timer(0.125).timeout
		await get_tree().create_timer(2.0).timeout
		GameManager.change_level(load("res://Scenes/Levels/Menus/MissionClearScreen.tscn"))
