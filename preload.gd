extends Node


const EXPLOSION_PARTICLES = preload("res://entities/tetromino/explode_particles.tscn")
const FILL_PARTICLES = preload("res://entities/tetromino/fill_particles.tscn")
const LINE_PARTICLES = preload("res://entities/tetromino/line_particles.tscn")
const BLOCK = preload("res://entities/tetromino/block.tscn")

@onready var explode_sound = AudioStreamPlayer.new()
@onready var repair_sound = AudioStreamPlayer.new()

func _ready() -> void:
	explode_sound.stream = load("res://addons/sounds/explosion.ogg")
	repair_sound.stream = load("res://addons/sounds/reversedshatter.ogg")
	repair_sound.max_polyphony = 1
	explode_sound.max_polyphony = 1
	add_child(explode_sound)
	add_child(repair_sound)
