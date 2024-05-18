extends Node
class_name AudioManager

# Declaring the three soundtrack nodes
@onready var levelMusic : AudioStreamPlayer = $"Level Music"
@onready var fishCloseMusic : AudioStreamPlayer = $"Fish Close"
@onready var fishChasingMusic : AudioStreamPlayer = $"Fish Chasing"

#Player and Angler Fish References
@export var player : CharacterBody2D
@export var anglerFish : CharacterBody2D

var enemyDistance : float
var musicTransitionTime : float = 2

enum DangerLevel {LOW, MID,  HIGH}
var currentDangerLevel : DangerLevel

var transitioning : bool = false

func _ready() -> void:
	fishCloseMusic.set_volume_db(-80.0)
	fishChasingMusic.set_volume_db(-80.0)
	SetDangerLevel(DangerLevel.LOW)
	

func _process(_delta: float) -> void:
	#calculate distance between player and angler
	enemyDistance = player.position.distance_to(anglerFish.position)
	#print(enemyDistance)
	if enemyDistance <= 200:
		SetDangerLevel(DangerLevel.HIGH)
	elif enemyDistance > 200 and enemyDistance <= 500:
		SetDangerLevel(DangerLevel.MID)
	elif enemyDistance > 500:
		SetDangerLevel(DangerLevel.LOW)

func SetDangerLevel(new_dangerLevel : DangerLevel) -> void:
	if currentDangerLevel == new_dangerLevel:
		return
	currentDangerLevel = new_dangerLevel
	EnterDangerLevel()
	
func EnterDangerLevel() -> void:
	match currentDangerLevel:
		DangerLevel.LOW:
			set_music_volumes(-80.0, -80.0)
		DangerLevel.MID:
			set_music_volumes(0.0, -80.0)
		DangerLevel.HIGH:
			set_music_volumes(0.0, 0.0)


func set_music_volumes(closeVolume : float, chaseVolume: float) -> void:
	var startVolumeClose = fishCloseMusic.get_volume_db()
	var startVolumeChase = fishChasingMusic.get_volume_db()
	
	var targetCloseVolume = closeVolume
	var targetChaseVolume = chaseVolume
	
	transitioning = true
	var elapsedTime = 0.0
	while elapsedTime < musicTransitionTime:
		var t = elapsedTime / musicTransitionTime
		#t = t * t * (3.0 - 2.0 * t)  # Cubic interpolation

		var newVolumeClose = lerp(startVolumeClose, targetCloseVolume, t)
		fishCloseMusic.set_volume_db(newVolumeClose)

		var newVolumeChasing = lerp(startVolumeChase, targetChaseVolume, t)
		fishChasingMusic.set_volume_db(newVolumeChasing)

		await(get_tree().create_timer(0.1).timeout)  # Wait for a short interval
		elapsedTime += 0.1

	# Ensure volume reaches exactly target volume at the end
	fishCloseMusic.set_volume_db(targetCloseVolume)
	fishChasingMusic.set_volume_db(targetChaseVolume)
	transitioning = false

