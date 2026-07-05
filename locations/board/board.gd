extends Node2D

const STARTING_LIVES = 2

@export var player : CharacterBody2D

var tetromino : Node2D
var start_time = 0
var temporary_nodes : Array[Node] = []
var lives = 2:
	set(value):
		lives = value
		if lives < 0:
			_fail()
		update_ui.emit()

var player_invulnerable = false

@onready var tetromino_node = load("res://entities/tetromino/tetromino.tscn")

signal update_ui

func _ready() -> void:
	update_ui.emit()
	tetromino = tetromino_node.instantiate()
	add_child(tetromino)
	_start_game()
	player.crushed.connect(_player_crushed)
	pass

func _player_crushed() -> void:

func _player_crushed() -> void:
	if not player_invulnerable:
		player_invulnerable = true
		player.position = Vector2(0, -580)
		lives -= 1


func _physics_process(_delta: float) -> void:
	player_invulnerable = false


func _fail() -> void:
	_start_game()



func _start_game() -> void:

	lives = STARTING_LIVES
	update_ui.emit()
	tetromino.position = Vector2(-16, -368)
	tetromino.start_time = Time.get_ticks_msec()
	tetromino.grounded.connect(_lock_tetromino)
	tetromino._load_block(randi() % 7)
	player.active = false
	tetromino.active = true
	for i in temporary_nodes:
		if i:
			i.queue_free()
	temporary_nodes = []

func _lock_tetromino():
	for block in tetromino.blocks:
		var pos = block.global_position
		var copy = block.duplicate()
		add_child(copy)
		copy.collision_layer = 2
		copy.global_position = pos
		temporary_nodes.append(copy)
	tetromino.position = Vector2(-16, -368)
	tetromino._load_block(randi() % 7)
	player.velocity.y = -100

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch"):
		if player.active:
			player.active = false
			tetromino.active = true
		else:
			player.active = true
			tetromino.active = false
