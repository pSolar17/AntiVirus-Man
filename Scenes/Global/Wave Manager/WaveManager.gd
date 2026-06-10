extends Node

# Global Node that holds wave data.
# Bullet: waves that have enemies that shoot bullets at the player.
# Laser: waves that have enemies that utilize laser attacks.
# Spawn: waves that have enemies that rely on spawning other enemies to fight.
# Final: final section waves. They can have different type enemies in the same wave.
@export
var wave_data : Dictionary[String, Array] = {
	"bullet" : [
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/WaveBullet1.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/WaveBullet2.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/WaveBullet3.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/WaveBullet4.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/WaveBullet5.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/WaveBullet6.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/WaveBullet7.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/WaveBullet8.tscn"),
		],
	"bullet_boss" : [
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/Boss/BulletBoss1.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/Boss/BulletBoss2.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/Boss/BulletBoss3.tscn"),
		],
	"laser" : [
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/LaserWave1.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/LaserWave2.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/LaserWave3.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/LaserWave4.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/LaserWave5.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/LaserWave6.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/LaserWave7.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/LaserWave8.tscn"),
		],
	"laser_boss" : [
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/Boss/LaserBoss1.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/Boss/LaserBoss2.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/Boss/LaserBoss3.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Laser/Boss/LaserBoss4.tscn"),
		],
	"spawn" : [
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/SpawnWave1.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/SpawnWave2.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/SpawnWave3.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/SpawnWave4.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/SpawnWave5.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/SpawnWave6.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/SpawnWave7.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/SpawnWave8.tscn"),
		],
	"spawn_boss" : [
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/Boss/SpawnBoss1.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/Boss/SpawnBoss2.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/Boss/SpawnBoss3.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/Boss/SpawnBoss4.tscn"),
		],
	"final" : [
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final1.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final2.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final3.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final4.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final5.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final6.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final7.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final8.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final9.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final10.tscn"),
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/Final11.tscn"),
		],
	"final_boss" : [
			preload("res://Scenes/Objects/Other/Wave/WavePrefabs/Final/FinalBoss.tscn")
		],
	"test" : [
			#load("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/Boss/SpawnBoss1.tscn"),
			#load("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/Boss/SpawnBoss2.tscn"),
			#load("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/Boss/SpawnBoss3.tscn"),
			#load("res://Scenes/Objects/Other/Wave/WavePrefabs/Spawn/Boss/SpawnBoss4.tscn"),
			#load("res://Scenes/Objects/Other/Wave/WavePrefabs/Bullet/Boss/BulletBoss1.tscn"),
		],
	"tutorial" : [
		
		]
}

func get_wave_data_for_section(section : String) -> Array:
	var result = []
	if section in ["bullet", "spawn", "laser", "final", "test", "tutorial"]:
		var wave_data_copy = wave_data[section].duplicate()
		for i in 4:
			wave_data_copy.shuffle()
			var wave = wave_data_copy.pop_front()
			if wave:
				result.push_back(wave)
		if section in ["bullet", "spawn", "laser", "final"]:
			result.push_back(wave_data[section + "_boss"].pick_random())
	
	return result
