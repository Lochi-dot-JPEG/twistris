extends Node2D

const STARTING_LIVES = 2
const TILE_SIZE = 32
const BOTTOM_LEFT_TILE = Vector2(-150,300)
const PLAYER_SPAWN = Vector2(0, -580)

@export var player : CharacterBody2D
@onready var liquid : Node2D = $Liquid

var tetromino : Node2D
var start_time = 0
var temporary_nodes : Array[Node] = []
var score = 0
var lives = 2:
	set(value):
		lives = value
		if lives < 0:
			_fail()
		update_ui.emit()
		liquid.height = 0

var player_invulnerable = false

var block_bag = []

@onready var tetromino_node = load("res://entities/tetromino/tetromino.tscn")

signal update_ui

func _ready() -> void:
	update_ui.emit()
	tetromino = tetromino_node.instantiate()
	add_child(tetromino)
	_start_game()
	player.crushed.connect(_player_crushed)
	tetromino.soft_drop.connect(_add_score.bind(1))

func _add_score(change : int):
	score += change
	update_ui.emit()

func _player_crushed() -> void:
	if not player_invulnerable:
		player_invulnerable = true
		player.position = PLAYER_SPAWN 
		lives -= 1


func _physics_process(_delta: float) -> void:
	player_invulnerable = false


func _fail() -> void:
	_start_game()

func _get_next_block() -> int:
	if block_bag.is_empty():
		block_bag = range(7)
		block_bag.shuffle()
	return block_bag.pop_back()



func _start_game() -> void:
	lives = STARTING_LIVES
	update_ui.emit()
	tetromino.position = Vector2(-16, -368)
	tetromino.start_time = Time.get_ticks_msec()
	tetromino.grounded.connect(_lock_tetromino)
	tetromino._load_block(_get_next_block())
	player.active = false
	player.position = PLAYER_SPAWN 
	tetromino.active = true
	for i in temporary_nodes:
		if i:
			i.queue_free()
	temporary_nodes = []


func _check_lines():
	var query = PhysicsPointQueryParameters2D.new()
	query.collision_mask = 2
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var cleared_lines = 0
	
	for y in range(21):
		var colliders = []
		for x in range(10):
			query.position = BOTTOM_LEFT_TILE + Vector2(x,-y) * TILE_SIZE
			var col = get_world_2d().direct_space_state.intersect_point(query, 1)
			if col.size() > 0:
				colliders.append(col[0]["collider"])
		if y == 20 && colliders.size() > 0:
			_fail()
		if colliders.size() == 10:
			var collider_y = 0
			for i in colliders:
				i.queue_free()
				collider_y = i.global_position.y
			for i in temporary_nodes:
				if i and i.global_position.y < collider_y:
					i.position.y += 32
			cleared_lines += 1
	
	match cleared_lines:
		1:
			score += 400
			update_ui.emit()
		2:
			score += 1200
			update_ui.emit()
		3:
			score += 2000
			update_ui.emit()
		4:
			score += 3200
			update_ui.emit()


	liquid.height -= cleared_lines * 40
	liquid.height = clamp(liquid.height, 0, 4000)



func _lock_tetromino():
	var last_copy : Node
	for block in tetromino.blocks:
		var pos = block.global_position
		var copy = block.duplicate()
		add_child(copy)
		copy.collision_layer = 2
		copy.global_position = pos
		temporary_nodes.append(copy)
		last_copy = copy
	tetromino.position = Vector2(-16, -368)
	tetromino._load_block(_get_next_block())
	player.velocity.y = -100

	if not last_copy.is_node_ready():
		await last_copy.ready
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	_check_lines()
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch"):
		if player.active:
			player.active = false
			tetromino.active = true
		else:
			player.active = true
			tetromino.active = false
