extends Node2D


# Types
# 0 line
# 1 square
# 2 L
# 3 Reverse L
# 4 T
# 5 Z
# 5 S

const TYPE_COLORS = [
	Color("#73bed3"),
	Color("#ecc166"),
	Color("#e1875c"),
	Color("#585aca"),
	Color("#be65bf"),
	Color("#cd5454"),
	Color("#a8ca85")
	]

const LINE_WALL_KICK_CHECKS = [
#0->1	
	[ Vector2( 0, 0), Vector2(-2, 0), Vector2(+1, 0), Vector2(-2,-1), Vector2(+1,+2) ],
#1->0	
	[ Vector2( 0, 0), Vector2(+2, 0), Vector2(-1, 0), Vector2(+2,+1), Vector2(-1,-2) ],
#1->2	
	[ Vector2( 0, 0), Vector2(-1, 0), Vector2(+2, 0), Vector2(-1,+2), Vector2(+2,-1) ],
#2->1	
	[ Vector2( 0, 0), Vector2(+1, 0), Vector2(-2, 0), Vector2(+1,-2), Vector2(-2,+1) ],
#2->3	
	[ Vector2( 0, 0), Vector2(+2, 0), Vector2(-1, 0), Vector2(+2,+1), Vector2(-1,-2) ],
#3->2	
	[ Vector2( 0, 0), Vector2(-2, 0), Vector2(+1, 0), Vector2(-2,-1), Vector2(+1,+2) ],
#3->0	
	[ Vector2( 0, 0), Vector2(+1, 0), Vector2(-2, 0), Vector2(+1,-2), Vector2(-2,+1) ],
#0->3	
	[ Vector2( 0, 0), Vector2(-1, 0), Vector2(+2, 0), Vector2(-1,+2), Vector2(+2,-1) ],
]

const WALL_KICK_CHECKS = [ 
#0->1
	[ Vector2( 0, 0), Vector2(-1, 0), Vector2(-1,+1), Vector2( 0,-2), Vector2(-1,-2) ],
#1->0
	[ Vector2( 0, 0), Vector2(+1, 0), Vector2(+1,-1), Vector2( 0,+2), Vector2(+1,+2) ],
#1->2
	[ Vector2( 0, 0), Vector2(+1, 0), Vector2(+1,-1), Vector2( 0,+2), Vector2(+1,+2) ],
#2->1
	[ Vector2( 0, 0), Vector2(-1, 0), Vector2(-1,+1), Vector2( 0,-2), Vector2(-1,-2) ],
#2->3
	[ Vector2( 0, 0), Vector2(+1, 0), Vector2(+1,+1), Vector2( 0,-2), Vector2(+1,-2) ],
#3->2
	[ Vector2( 0, 0), Vector2(-1, 0), Vector2(-1,-1), Vector2( 0,+2), Vector2(-1,+2) ],
#3->0
	[ Vector2( 0, 0), Vector2(-1, 0), Vector2(-1,-1), Vector2( 0,+2), Vector2(-1,+2) ],
#0->3
	[ Vector2( 0, 0), Vector2(+1, 0), Vector2(+1,+1), Vector2( 0,-2), Vector2(+1,-2) ],
]

const BLOCK_POSITIONS = [
	# Line
	[
		[ # Unrotated
			[-1,0], [0,0], [1,0], [2,0] ],
		[ # 90degrees
			[1,-1], [1,0], [1,1],  [1,2] ],
		[ # 180degrees
			[2,1], [1,1], [0,1], [-1,1] ],
		[ # 270degrees
			 [0,2], [0,1], [0,0], [0,-1] ],
	],

	[ # Square
		[ # Unrotated
			[1,0], [1,1], [0,1], [0,0] ],
		[ # 90degrees
			[1,1], [0,1], [0,0], [1,0]  ],
		[ # 180degrees
			[0,1], [0,0], [1,0], [1,1]  ],
		[ # 270degrees
			[0,0], [1,0], [1,1], [0,1] ],
	],
	[ # L
		[ # Unrotated
			[0,0], [-1,0], [1,0], [1,-1] ],
		[ # 90degrees
			[0,0], [0,-1], [0,1], [1,1] ],
		[ # 180degrees
			[0,0], [1,0], [-1,0], [-1,1] ],
		[ # 270degrees
			[0,0], [0,1], [0,-1], [-1,-1] ],
	],
	[ # Reverse L
		[ # Unrotated
		[0,0], [1,0], [-1,0], [-1,-1] ],
		[ # 90degrees
		[0,0], [0,1], [0,-1], [1,-1] ],
		[ # 180degrees
		[0,0], [-1,0], [1,0], [1,1] ],
		[ # 270degrees
		[0,0], [0,-1], [0,1], [-1,1] ],
	],
	[ # T
		[ # Unrotated
			[0,0], [1,0], [-1,0], [0,-1] ],
		[ # 90degrees
			[0,0], [0,1], [0,-1], [1,0] ],
		[ # 180degrees
			[0,0], [-1,0], [1,0], [0,1] ],
		[ # 270degrees
			[0,0], [0,-1], [0,1], [-1,0] ],
	],
	[ # Z
		[ # Unrotated
			[0,0], [1,0], [0,-1], [-1,-1] ],
		[ # 90degrees
			[0,0], [0,1], [1,0], [1,-1] ],
		[ # 180degrees
			[0,0], [-1,0], [0,1], [1,1] ],
		[ # 270degrees
			[0,0], [0,-1], [-1,0], [-1,1] ],
	],
	[ # S
		[ # Unrotated
			[0,0], [-1,0], [0,-1], [1,-1] ],
		[ # 90degrees
			[0,0], [0,-1], [1,0], [1,1] ],
		[ # 180degrees
			[0,0], [1,0], [0,1], [-1,1] ],
		[ # 270degrees
			[0,0], [0,1], [-1,0], [-1,-1] ],
	],
]
const DROP_TIME = 1
const TIME_DROP_INCREASE = 0.002 # Time removed from drop time each second
const MAX_TIME_AFFECT = 180000 # Max milliseconds to continue increasing drop speed
const DAS_DELAY = 150# delay between first hit and repeating (ms)
const AUTO_REPEAT_RATE = 100 # milliseconds to repeat a move action

@onready var blocks : Array[CharacterBody2D] = [ 
	get_node("%block"),
	get_node("%block2"),
	get_node("%block3"),
	get_node("%block4"),
]

@onready var move_sound : AudioStreamPlayer = $AudioStreamPlayer
@onready var ghost : Node2D = $Ghost
@onready var ghost_blocks : Array[CharacterBody2D] = [ 
	get_node("%ghost_block"),
	get_node("%ghost_block2"),
	get_node("%ghost_block3"),
	get_node("%ghost_block4"),
]

var active = true
var piece_rotation := 0
var type := 0
var since_last_drop := 0.0
var start_time = 0
var move_cooldown = 0
var time_since_right_pressed := 0.0
var time_since_left_pressed := 0.0

signal grounded
signal soft_drop
signal hard_drop

func _ready() -> void:
	for block in blocks:
		for b in blocks:
			if b != block:
				block.add_collision_exception_with(b)


func _load_block(_type: int, bugged := false) -> void:
	type = _type
	var bugged_block_index = randi() % 4
	for i in 4:
		var block_is_bugged = bugged and bugged_block_index == i
		var block = blocks[i]
		var ghost_block = ghost_blocks[i]

		if block_is_bugged:
			block.modulate = Color.GRAY
			ghost_block.modulate = Color.GRAY
		else:
			block.modulate = TYPE_COLORS[type]
			ghost_block.modulate = TYPE_COLORS[type]
		block.get_node("%Bugged").visible = block_is_bugged
		ghost_block.modulate.a = 0.5
		ghost_block.get_node("%Bugged").visible = block_is_bugged

	piece_rotation = 0
	_load_rotation()


func _load_rotation() -> void:
	for i in 4:
		var pos = BLOCK_POSITIONS[type][piece_rotation][i]
		blocks[i].position.x = pos[0] * 32
		blocks[i].position.y = pos[1] * 32
		ghost_blocks[i].position.x = pos[0] * 32
		ghost_blocks[i].position.y = pos[1] * 32
	_update_ghost_blocks()


func _update_ghost_blocks() -> void:
	var max_drop = 0
	for i in range(1,25):
		if not _can_move_direction(Vector2(0,i)):
			max_drop = i-1
			break
	ghost.position = Vector2(0, max_drop * 32)


func _try_move_direction(dir: Vector2) -> bool:
	if _can_move_direction(dir):
		position += dir * 32
		_update_ghost_blocks()
		return true
	return false


func _can_move_direction(dir: Vector2) -> bool:
	var query = PhysicsPointQueryParameters2D.new()
	query.collision_mask = 2
	query.collide_with_bodies = true
	for i in blocks:
		query.position = i.global_position + dir*32 + Vector2(10,10)

		var col = get_world_2d().direct_space_state.intersect_point(query, 1)

		if col.size() != 0:
			return false
	return true


func _process(delta: float) -> void:
	since_last_drop += delta
	var drop_time = clampf(Time.get_ticks_msec() - start_time,0,MAX_TIME_AFFECT) / 1000.0
	var speed = clamp((DROP_TIME - drop_time * TIME_DROP_INCREASE), 0.1, DROP_TIME)

	if Input.is_action_just_pressed("harddrop"):
		for i in range(30):
			if not _try_move_direction(Vector2(0,1)):
				grounded.emit()
				break
			hard_drop.emit()

	while since_last_drop > speed:
		since_last_drop -= speed
		var moved = _try_move_direction(Vector2(0,1))
		if not moved:
			grounded.emit()
		if Input.is_action_pressed("softdrop"):
			soft_drop.emit()

	if active:

		# Move piece right
		if Input.is_action_just_pressed("right"):
			if _try_move_direction(Vector2(1,0)):
				move_sound.play()

		if Input.is_action_pressed("right"):
			var before_mod_auto_repeat = int((time_since_right_pressed - DAS_DELAY) / AUTO_REPEAT_RATE)
			time_since_right_pressed += delta * 1000
			print(time_since_right_pressed)
			print(before_mod_auto_repeat)
			var after_mod_auto_repeat = int((time_since_right_pressed - DAS_DELAY) / AUTO_REPEAT_RATE)
			print(before_mod_auto_repeat - after_mod_auto_repeat)
			if time_since_right_pressed > DAS_DELAY and int(after_mod_auto_repeat) != int(before_mod_auto_repeat):
				if _try_move_direction(Vector2(1,0)):
					move_sound.play()
		else:
			time_since_right_pressed = 0

		if Input.is_action_just_pressed("left"):
			if _try_move_direction(Vector2(-1,0)):
				move_sound.play()

		if Input.is_action_pressed("left"):
			var before_mod_auto_repeat = int((time_since_left_pressed - DAS_DELAY) / AUTO_REPEAT_RATE)
			time_since_left_pressed += delta * 1000
			print(time_since_left_pressed)
			print(before_mod_auto_repeat)
			var after_mod_auto_repeat = int((time_since_left_pressed - DAS_DELAY) / AUTO_REPEAT_RATE)
			print(before_mod_auto_repeat - after_mod_auto_repeat)
			if time_since_left_pressed > DAS_DELAY and int(after_mod_auto_repeat) != int(before_mod_auto_repeat):
				if _try_move_direction(Vector2(-1,0)):
					move_sound.play()
		else:
			time_since_left_pressed = 0

		if Input.is_action_just_pressed("rotate"):
			_rotate(1)
		if Input.is_action_just_pressed("rotateccw"):
			_rotate(-1)
		if Input.is_action_pressed("softdrop"):
			since_last_drop += delta * 20


	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_1):
			_load_block(1)
		if Input.is_key_pressed(KEY_2):
			_load_block(2)
		if Input.is_key_pressed(KEY_3):
			_load_block(3)
		if Input.is_key_pressed(KEY_4):
			_load_block(4)
		if Input.is_key_pressed(KEY_5):
			_load_block(5)
		if Input.is_key_pressed(KEY_6):
			_load_block(6)
		if Input.is_key_pressed(KEY_7):
			_load_block(0)


func _rotate(amount := 1):
	var kick_type_index = 0

	if piece_rotation == 0 && amount == 1: kick_type_index = 0 #0->1
	elif piece_rotation == 1 && amount == -1: kick_type_index = 1 #1->0
	elif piece_rotation == 1 && amount == 1: kick_type_index = 2 #1->2
	elif piece_rotation == 2 && amount == -1: kick_type_index = 3 #2->1
	elif piece_rotation == 2 && amount == 1: kick_type_index = 4 #2->3
	elif piece_rotation == 3 && amount == -1: kick_type_index = 5 #3->2
	elif piece_rotation == 3 && amount == 1: kick_type_index = 6 #3->0
	elif piece_rotation == 0 && amount == -1: kick_type_index = 7 #0->3
	else: kick_type_index = 0

	var kicks
	if type == 0:
		kicks = LINE_WALL_KICK_CHECKS[kick_type_index]
	else:
		kicks = WALL_KICK_CHECKS[kick_type_index]

	piece_rotation += amount 
	while piece_rotation < 0:
		piece_rotation += 4
	while piece_rotation > 3:
		piece_rotation -= 4
	_load_rotation()
	var can_move = false

	# Check each kick position if free
	for kick in kicks:
		if _try_move_direction(kick):
			can_move = true
			break

	# If nothing is possible, unrotate
	if not can_move:
		piece_rotation -= amount 
		while piece_rotation < 0:
			piece_rotation += 4
		while piece_rotation > 3:
			piece_rotation -= 4
		_load_rotation()
