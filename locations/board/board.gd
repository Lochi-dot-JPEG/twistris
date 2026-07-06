extends Node2D

const TILE_SIZE = 32
const BOTTOM_LEFT_TILE = Vector2(-150,300)
const PLAYER_SPAWN = Vector2(0, -580)


const ADJACENT_POSITIONS = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT,
]

const fill_points = [
	Vector2(0,0),
	Vector2(1,0),
	Vector2(2,0),
	Vector2(-1,0),
	Vector2(-2,0),

	Vector2(0,1),
	Vector2(0,2),
	Vector2(0,-1),
	Vector2(0,-2),

	Vector2(1,1), # Corners
	Vector2(-1,1),
	Vector2(1,-1),
	Vector2(-1,-1),
]

var tetromino : Node2D
var start_time = 0
var temporary_nodes : Array[Node] = []
var score = 0


var block_bag = []
var bag_bug_block1 = 0
var bag_bug_block2 = 0

@onready var tetromino_node = load("res://entities/tetromino/tetromino.tscn")
@onready var kid_node = load("res://entities/kid/kid.tscn")
@onready var explosion_shape = CircleShape2D.new()

signal update_ui
signal failed

func _ready() -> void:
	explosion_shape.radius = 60
	update_ui.emit()
	tetromino = tetromino_node.instantiate()
	add_child(tetromino)
	_start_game()
	tetromino.soft_drop.connect(_add_score.bind(1))
	tetromino.hard_drop.connect(_add_score.bind(2))

func _add_score(change : int):
	score += change
	update_ui.emit()

func _bug_crushed() -> void:
	score += 400

func _get_next_block() -> int:
	if block_bag.is_empty():
		block_bag = range(7)
		block_bag.shuffle()
		bag_bug_block1 = randi() % 7
		bag_bug_block2 = randi() % 7
	return block_bag.pop_back()



func _start_game() -> void:

	tetromino.show()
	process_mode = Node.PROCESS_MODE_INHERIT
	update_ui.emit()
	tetromino.position = Vector2(-16, -368)
	tetromino.start_time = Time.get_ticks_msec()
	if not tetromino.is_connected("grounded", _lock_tetromino):
		tetromino.grounded.connect(_lock_tetromino)

	var next_block =_get_next_block()
	tetromino._load_block(next_block, bag_bug_block2 == next_block or bag_bug_block1 == next_block)

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
	var cleared_line_heights = []
	var fill_positions = []
	
	for y in range(21):
		var colliders = []
		for x in range(10):
			query.position = BOTTOM_LEFT_TILE + Vector2(x,-y) * TILE_SIZE
			var col = get_world_2d().direct_space_state.intersect_point(query, 1)
			if col.size() > 0:
				colliders.append(col[0]["collider"])
		if y == 20 && colliders.size() > 0:
			failed.emit()

		# Check if line cleared
		if colliders.size() == 10:
			var bug_positions = []
			var collider_y = 0

			for i in colliders:
				# Check each collider for being a bug
				var bug = i.get_node_or_null("%Bugged")
				if bug and bug.visible:
					bug.visible = false
					bug_positions.append(bug.global_position)

			if bug_positions.size() == 1: # Explode when one bug
				_explode_at_point(bug_positions[0])
			else: # Clear line otherwise
				for i in colliders:
					i.queue_free()
					collider_y = i.global_position.y
				cleared_line_heights.append(collider_y)
				var new_line_particles = Preload.LINE_PARTICLES.instantiate()
				add_child(new_line_particles)
				new_line_particles.global_position = Vector2(0,collider_y + 16)
				cleared_lines += 1
				for i in temporary_nodes:
					if i and i.global_position.y < collider_y:
						i.position.y += 32
				if bug_positions.size() > 1:
					fill_positions.append_array(bug_positions)


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


	if not fill_positions.is_empty():
		await get_tree().physics_frame
		await get_tree().physics_frame
		for i in fill_positions:
			_fill_at_point(i)
		await get_tree().physics_frame
		await get_tree().physics_frame
		_check_lines()


func _explode_at_point(point: Vector2):
	Preload.explode_sound.play()
	var new_explosion = Preload.EXPLOSION_PARTICLES.instantiate()
	add_child(new_explosion)
	new_explosion.global_position = point
	var params = PhysicsShapeQueryParameters2D.new()
	params.transform.origin = point
	params.shape = explosion_shape
	var intersections = get_world_2d().direct_space_state.intersect_shape(params)
	for i in intersections:
		var collider = i.collider
		var bug = collider.get_node_or_null("%Bugged")

		if bug and collider:
			if bug.visible:
				bug.hide()
				_explode_at_point(bug.global_position)
			collider.queue_free()

func _stop_game() -> void:
	for i in temporary_nodes:
		if i:
			i.queue_free()
	temporary_nodes = []
	tetromino.hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	


func _fill_at_point(point: Vector2):
	var new_fill_particles = Preload.FILL_PARTICLES.instantiate()
	Preload.repair_sound.play()
	add_child(new_fill_particles)
	new_fill_particles.global_position = point

	var params = PhysicsShapeQueryParameters2D.new()
	params.transform.origin = point
	params.shape = explosion_shape
	var intersections = get_world_2d().direct_space_state.intersect_shape(params)
	var present_positions = []
	for i in intersections:
		var collider = i.collider
		present_positions.append(collider.global_position)
		var bug = collider.get_node_or_null("%Bugged")
		if bug and bug.visible:
			bug.hide()
			_fill_at_point(bug.global_position)

	for i in fill_points:
		var test = point + (i * TILE_SIZE)
		if test.x < -160 or test.x > 160:
			continue
		if test.y > 320 or test.x < -320:
			continue
		if not (test in present_positions):
			var new_cell = Preload.BLOCK.instantiate()
			add_child(new_cell)
			new_cell.global_position = test
			temporary_nodes.append(new_cell)
			new_cell.collision_layer = 2
			new_cell.modulate = Color.GRAY



func _lock_tetromino():
	var last_copy : Node
	for block in tetromino.blocks:
		var bug = block.get_node_or_null("%Bugged")
		if bug and bug.visible:

			var query = PhysicsPointQueryParameters2D.new()
			query.collision_mask = 2
			query.collide_with_bodies = true
			query.collide_with_areas = false
			for side in ADJACENT_POSITIONS:
				query.position = block.global_position + side * TILE_SIZE
				var col = get_world_2d().direct_space_state.intersect_point(query, 1)
				for adjacent_block in col:
					var adjacent_block_bug = adjacent_block["collider"].get_node_or_null("%Bugged")
					if adjacent_block_bug and adjacent_block_bug.visible:
						adjacent_block_bug.visible = false
						bug.visible = false
						var new_type = _get_next_block()
						score += 1500
						block_bag = [
							new_type,
							new_type,
							new_type,
							new_type,
							new_type
						]
		var pos = block.global_position
		var copy = block.duplicate()
		add_child(copy)
		copy.collision_layer = 2
		copy.global_position = pos
		temporary_nodes.append(copy)
		last_copy = copy

	tetromino.position = Vector2(-16, -368)
	var next_block =_get_next_block()


	# TODO fix this hacky workaround, get rid of piece lag
	if not last_copy.is_node_ready():
		await last_copy.ready
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	_check_lines()
	await get_tree().physics_frame

	tetromino._load_block(next_block, bag_bug_block2 == next_block or bag_bug_block1 == next_block)

