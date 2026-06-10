class_name Enemy
extends CharacterBody2D

## Base class for all enemies.

signal killed(enemy : Enemy)

## Enemy's maximum HP.
@export
var max_health : float = 100.0:
	set(value):
		max_health = max(value, 1.0)
		if current_health > max_health:
			current_health = max_health

@onready
var current_health : float = max_health:
	set(value):
		current_health = clamp(value, 0.0, max_health)
		if is_zero_approx(current_health):
			die()

## The enemy's kill reward, added to the score.
@export
var bounty : int = 150

## The enemy's RNA drop.
@export
var rna_bounty : int = 100

## The enemy's DNA drop.
@export
var dna_bounty : int = 0

## If true - contact damage is enabled for this enemy.
@export
var damage_on_contact : bool = true

## Enemy's contact damage.
@export
var contact_damage : float = 20.0

## Health magnification. This is applied after wave and clear bonuses.
@export
var health_magnification : float = 1.0

## Damage magnification. This is applied after wave and clear bonuses.
@export
var damage_magnification : float = 1.0

## If true - considered a boss, showing an HP bar.
## It's recommended that only one enemy per wave is set as boss.
@export
var is_boss : bool = false

func _ready() -> void:
	# Set stats in accordance with current game state.
	max_health = max_health * (1.0 + GameManager.MAGNIFICATION_PER_WAVE * GameManager.wave + GameManager.MAGNIFICATION_PER_CLEAR * GameManager.state.clears)
	max_health = health_magnification * max_health
	current_health = max_health
	
	contact_damage = contact_damage * damage_magnification
	
	# Register itself
	GameManager.register_enemy(self)

func _physics_process(delta: float) -> void:
	for body in $EnemyHitbox.get_overlapping_bodies():
		if body is Player:
			body.take_damage(contact_damage)
	
	# Check position, if too far away from the screen - destroy
	if global_position.x < -640.0 or global_position.length() > 4096.0:
		die()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		GameManager.enemies.erase(self)

func take_damage(value : float):
	print("Enemy %s is taking %.2f damage!" % [name, value])
	GameManager.get_node("EnemyHitSound").play()
	
	# Hurt animation
	var spr_material : Material = $Sprite.material
	if spr_material is ShaderMaterial:
		spr_material.set_shader_parameter("enabled", true)
		await get_tree().create_timer(4.0/60.0).timeout
		spr_material.set_shader_parameter("enabled", false)
	
	current_health -= value

func die():
	GameManager.add_score(bounty)
	GameManager.add_rna(rna_bounty)
	GameManager.add_dna(dna_bounty)
	var explosion : Node2D = GameManager.spawn_packed(preload("res://Scenes/Objects/Other/ExplosionObject.tscn"), global_position)
	explosion.scale = self.scale
	killed.emit(self)
	queue_free()
