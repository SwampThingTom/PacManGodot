class_name AudioManager
extends Node

const SIREN_STREAMS: Array[AudioStream] = [
    preload("res://assets/audio/siren/siren_1.wav"),
    preload("res://assets/audio/siren/siren_2.wav"),
    preload("res://assets/audio/siren/siren_3.wav"),
    preload("res://assets/audio/siren/siren_4.wav"),
    preload("res://assets/audio/siren/siren_5.wav"),
]

@onready var _siren: AudioStreamPlayer = $SirenPlayer
var _siren_tier: int = -1
var _siren_enabled: bool = false

@onready var _frightened: AudioStreamPlayer = $FrightenedPlayer
@onready var _start_game: AudioStreamPlayer = $StartGamePlayer
@onready var _intermission: AudioStreamPlayer = $IntermissionPlayer

# Use two audio channels for pellets so they overlap as Pac-Man eats pellets.
@onready var _eat_pellet: Array[AudioStreamPlayer] = [$EatPellet1Player, $EatPellet2Player]
var _pellet_index: int = 0

@onready var _eat_fruit: AudioStreamPlayer = $EatFruitPlayer
@onready var _eat_ghost: AudioStreamPlayer = $EatGhostPlayer
@onready var _extra_life: AudioStreamPlayer = $ExtraLifePlayer
@onready var _player_died: AudioStreamPlayer = $PlayerDiedPlayer


func play_start_game() -> void:
    _start_game.play()


func play_intermission() -> void:
    _intermission.play()


func play_eat_pellet() -> void:
    _eat_pellet[_pellet_index].play()
    _pellet_index = 1 - _pellet_index


func play_eat_fruit() -> void:
    _eat_fruit.play()


func play_eat_ghost() -> void:
    _eat_ghost.play()


func play_extra_life() -> void:
    _extra_life.play()


func play_player_died() -> void:
    _player_died.play()


# Siren

func start_siren(pellets_eaten: int) -> void:
    _frightened.stop()
    _siren_enabled = true
    _set_siren_tier(pellets_eaten, true)


func stop_siren() -> void:
    _siren_enabled = false
    _siren_tier = -1
    _siren.stop()
    _frightened.stop()
        


func start_frightened() -> void:
    stop_siren()
    _frightened.play()


func stop_frightened(pellets_eaten: int):
    start_siren(pellets_eaten)


func update_siren_for_pills(pellets_eaten: int) -> void:
    if not _siren_enabled:
        return
    _set_siren_tier(pellets_eaten, false)


func _set_siren_tier(pellets_eaten: int, force_restart: bool) -> void:
    var new_tier := _tier_for_pills(pellets_eaten)
    if not force_restart and new_tier == _siren_tier:
        return

    _siren_tier = new_tier
    _siren.stream = SIREN_STREAMS[_siren_tier]
    _siren.play()
    print("playing siren tier ", _siren_tier)


func _tier_for_pills(pellets_eaten: int) -> int:
    if pellets_eaten >= 228: return 4
    if pellets_eaten >= 212: return 3
    if pellets_eaten >= 180: return 2
    if pellets_eaten >= 116: return 1
    return 0
