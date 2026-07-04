extends Node

@onready var tetromino_node = load("res://entities/tetromino/tetromino.tscn")
var tetromino : Node2D
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
	tetromino.position = Vector2(-16, -368)
	tetromino._load_block(randi() % 7)



