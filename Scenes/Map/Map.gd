extends Navigation2D

const GENERAL_WALK_DISTANCE = 8  # Approx/close enough walk to amount
const GENERAL_DISTRACE_FROM_DEST = 20 # How close to get
const MAX_WALK_SPEED = 300

var TARGET_TO_MOVE

var begin = Vector2()
var end = Vector2()
var walk_path = []
var max_speed

func _process(delta):
	if walk_path and walk_path.size() > 1:
		print("DEBUG WALKING")
		max_speed = MAX_WALK_SPEED
		var pfrom = walk_path[walk_path.size() - 1]
		var pto = walk_path[walk_path.size() - 2]
		var distance = TARGET_TO_MOVE.position.distance_to(pto)
#		print("DEBUG: distnace=",distance)
		if distance <= GENERAL_DISTRACE_FROM_DEST:
			TARGET_TO_MOVE.input_direction = Vector2()
			walk_path.remove(walk_path.size() - 1)
			print("done walking")
		else:
			if int(TARGET_TO_MOVE.position.x) > int(pto.x) + GENERAL_WALK_DISTANCE:
				TARGET_TO_MOVE.input_direction = Vector2(-1, 0)
			elif int(TARGET_TO_MOVE.position.x) < int(pto.x) - GENERAL_WALK_DISTANCE:
				TARGET_TO_MOVE.input_direction = Vector2(1, 0)
			elif int(TARGET_TO_MOVE.position.y) > int(pto.y) + GENERAL_WALK_DISTANCE:
				TARGET_TO_MOVE.input_direction = Vector2(0, -1)
			elif int(TARGET_TO_MOVE.position.y) < int(pto.y) - GENERAL_WALK_DISTANCE:
				TARGET_TO_MOVE.input_direction = Vector2(0, 1)
			else:
				TARGET_TO_MOVE.input_direction = Vector2()
				print("on top done")

func _update_path():
	var p = get_simple_path(begin, end, true)
	walk_path = Array(p) # PoolVector2Array too complex to use, convert to regular array
	walk_path.invert()
	print("DEBUG: walk_path=", walk_path)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		begin = TARGET_TO_MOVE.position
		# Mouse to local navigation coordinates
		end = event.position - position
		_update_path()


func _ready():
	TARGET_TO_MOVE = $BL_TestMap/YSort/n30n