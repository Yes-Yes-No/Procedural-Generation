extends Node2D

export (PackedScene) var start_room

export (PackedScene) var up_room
export (PackedScene) var down_room
export (PackedScene) var left_room
export (PackedScene) var right_room

export (PackedScene) var up_end_room
export (PackedScene) var down_end_room
export (PackedScene) var left_end_room
export (PackedScene) var right_end_room

export (PackedScene) var up_shop_room
export (PackedScene) var down_shop_room
export (PackedScene) var left_shop_room
export (PackedScene) var right_shop_room

export (int) var max_rooms
export (float) var room_spacing

var current_rooms = 0
var current_direction = -1
var room_positions = []
var shopRoomSelected = false

var spawn_interval = 0.1

func _ready():
	randomize()
	generate_level()

func _physics_process(delta):
	if Input.is_action_just_pressed("generate"):
		get_tree().reload_current_scene()

func generate_level():
	var start_position = Vector2(0, 0)
	
#	max_rooms = randi() % 4 + 6
	
	spawn_room(start_room, start_position)
	room_positions.append(start_position)
	
	var current_position = start_position
	var previous_direction = -1
	
	for i in range(max_rooms - 2):  # Spawn exactly max_rooms - 2 regular rooms
		var direction = choose_direction()
		var new_position = current_position + get_offset(direction) * room_spacing
	
		var max_attempts = 20  # Adjust as needed
		while overlaps(new_position) and max_attempts > 0:
			direction = choose_direction()
			new_position = current_position + get_offset(direction) * room_spacing
			max_attempts -= 1
	
		current_position = new_position
		
		var isShopRoom = (not shopRoomSelected) and (randf() < 0.5)  # Adjust the probability (0.2) as needed
	
		# Call the appropriate function based on the direction
		if isShopRoom:
			spawn_appropriate_room(get_appropriate_shop_room_scene(direction), current_position)
			shopRoomSelected = true  # Mark a shop room as selected
		else:
			spawn_appropriate_room(get_appropriate_room_scene(direction), current_position)
	
		room_positions.append(current_position)
	
		previous_direction = direction
	
		# Delay before the next iteration
		yield(get_tree().create_timer(spawn_interval), "timeout")
	
	# Spawn the end room
	var direction = choose_direction()
	var new_position = current_position + get_offset(direction) * room_spacing
	
	var max_attempts = 20  # Adjust as needed
	while overlaps(new_position) and max_attempts > 0:
		direction = choose_direction()
		new_position = current_position + get_offset(direction) * room_spacing
		max_attempts -= 1
	
	current_position = new_position
	
	# Determine the appropriate end room based on the direction
	if direction == 0:  # up
		spawn_room(down_end_room, current_position)
	elif direction == 1:  # down
		spawn_room(up_end_room, current_position)
	elif direction == 2:  # left
		spawn_room(right_end_room, current_position)
	elif direction == 3:  # right
		spawn_room(left_end_room, current_position)
	
	room_positions.append(current_position)

func spawn_appropriate_room(room_scene, position):
	var room_instance = room_scene.instance()
	add_child(room_instance)
	room_instance.global_position = position

func get_appropriate_room_scene(direction):
	match direction:
		0:  # up
			return down_room
		1:  # down
			return up_room
		2:  # left
			return right_room
		3:  # right
			return left_room
		# Add other cases as needed

func spawn_room(room_scene, position):
	var room_instance = room_scene.instance()
	add_child(room_instance)
	room_instance.global_position = position

func choose_direction():
	# Define weights for each direction (adjust as needed)
	var weights = [5, 5, 5, 5]  # Higher weight, higher chance
	
	# Create an array to store all possible directions based on weights
	var weighted_directions = []
	
	for i in range(weights.size()):
		for j in range(weights[i]):
			weighted_directions.append(i)
	
	# Randomly choose a direction from the weighted directions
	current_direction = weighted_directions[randi() % weighted_directions.size()]
	
	return current_direction

func get_offset(dir):
	match dir:
		0:  # up
			return Vector2(0, -1)
		1:  # down
			return Vector2(0, 1)
		2:  # left
			return Vector2(-1, 0)
		3:  # right
			return Vector2(1, 0)

func overlaps(position):
	for p in room_positions:
		if position.distance_squared_to(p) < room_spacing * room_spacing:
			return true
	return false

func get_appropriate_shop_room_scene(direction):
	match direction:
		0:  # up
			return down_shop_room
		1:  # down
			return up_shop_room
		2:  # left
			return right_shop_room
		3:  # right
			return left_shop_room
		# Add other cases as needed
