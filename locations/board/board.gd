extends Node

@onready var tetromino_node = load("res://entities/tetromino/tetromino.tscn")
var tetromino : Node2D
@export var player : CharacterBody2D
var start_time = 0

func _ready() -> void:
	tetromino = tetromino_node.instantiate()
	add_child(tetromino)
	_start_game()
	pass

func _start_game():
	tetromino.position = Vector2(-16, -368)
	tetromino.start_time = Time.get_ticks_msec()
	tetromino.grounded.connect(_lock_tetromino)
	tetromino._load_block(randi() % 7)

func _lock_tetromino():
	for block in tetromino.blocks:
		var pos = block.global_position
		var copy = block.duplicate()
		add_child(copy)
		copy.global_position = pos
	tetromino.position = Vector2(-16, -368)
	tetromino._load_block(randi() % 7)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch"):
		if player.active:
			player.active = false
			tetromino.active = true
		else:
			player.active = true
			tetromino.active = false


