class_name GameState
extends Resource

# A dedicated Resource-based class that represent the current state of the Game.
# Note: this class does not store data related to mission. This data is lost upon setting the state.

# Current level ID.
var level_id : int = 0

# Player's upgrade levels.
# Missing entries are treated as zeroes.
@export
var upgrades : Dictionary = {
	"speed" : 0,
	"damage" : 0,
	"fire_rate" : 0,
	"health" : 0,
	"lives" : 0,
}

## Current player's score.
var score : int = 0:
	set(value):
		score = value
		if score > high_score:
			high_score = score

## Maximum score ever achieved by the player.
var high_score : int = 0

## Number of mission clears.
@export
var clears : int = 0:
	set(value):
		clears = value
		strains = [null, null, null, null, null]

## Player's current lives.
@export
var lives : int = 3

## Tutorial completion flag.
@export
var tutorial_complete : bool = false

## Player's strains.
@export
var strains : Array[Strain] = [
	null,
	null,
	null,
	null,
	null
]

## Player's currency no. 1, drops from regular enemies
@export
var rna : int = 0:
	set(value):
		rna = clamp(value, 0, 99999)

## Player's currency no. 2, drops from bosses
@export
var dna : int = 0:
	set(value):
		dna = clamp(value, 0, 99999)

## Ending value.
@export
var ending : int = 0

func save_to_file(file_path : String):
	var file : FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_var(upgrades)
		file.store_var(high_score)
		file.store_var(clears)
		# Store strains
		for strain in strains:
			if not strain:
				file.store_line("bepis")
			else:
				file.store_line(str(strain))
		file.store_16(rna)
		file.store_16(dna)
		file.store_64(ending)
		file.store_64(tutorial_complete)
		file.close()
		print("Successfully saved the state!")
	else:
		print("Unexpected error when writing to file %s" % file_path)

func read_from_file(file_path : String):
	var file : FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file:
		upgrades = file.get_var()
		high_score = file.get_var()
		clears = file.get_var()
		for i in strains.size():
			var strain_data : String = file.get_line()
			strains[i] = Strain._from_string(strain_data)
		rna = file.get_16()
		dna = file.get_16()
		ending = file.get_64()
		tutorial_complete = file.get_64()
		file.close()
		print("Successfully loaded the state!")
	else:
		print("Unexpected error when reading from file %s" % file_path)
