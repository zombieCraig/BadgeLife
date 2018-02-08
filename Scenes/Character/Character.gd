tool
extends KinematicBody2D

signal state_changed

const FRAME_UP = 104
const FRAME_LEFT = 117
const FRAME_DOWN = 130
const FRAME_RIGHT = 143

const MAX_WALK_SPEED = 300
const MAX_RUN_SEED = 350 # A little less than double WALK

const BUMP_SPEED = 400
const BUMP_DURATION = 0.1
const MAX_BUMP_HEIGHT = 50
var bump_direction = Vector2()
var bump_messages = [ "Umpf", "Hey!!!", "Watch it!", "Asshat!", "Seriously?!?", "I hate you" ]

const BASE_CHAR_IMG_PATH = "res://ArtSketeches/Character/"
const BODY_PATH = "Body/"
const HAIR_PATH = "Hair/"
const LEGS_PATH = "Legs/"
const TORSO_PATH = "Torso/"
const FEET_PATH = "Feet/"

var speed = 0.0
var max_speed = 0.0
var velocity = Vector2()

var input_direction = Vector2()
var last_move_direction = Vector2(1, 0)

# States
#  BUSY - Generically busy, won't move
#  IDLE - Idle, bored, will move around
#  MOVE - Walking or running
#  BUMP - Being bumped
enum STATES { BUSY, IDLE, MOVE, BUMP }
var state = null
enum { FACE_LEFT, FACE_RIGHT, FACE_UP, FACE_DOWN }
export(int, "left", "right", "up", "down") var face_dir setget set_face_dir
var skin_tones = [ "dark2", "dark", "light", "tanned", "tanned2" ]
var genders = [ "male", "female" ]
var hair_styles = [ "plain", "shorthawk", "bangs", "bangsshort", "bedhead", "longhawk" ]
var legwear = [ "pants" ]
var torsowear = [ "shirt" ]
var footwear = [ "shoes" ]
var base_gender = "male"
var base_skintone = "tanned"
var base_hair = null
var base_hair_color = Color()
var base_legwear = "pants"
var base_legwear_color = Color()
var base_torsowear = "shirt"
var base_torsowear_color = Color()
var base_footwear = "shoes"
var base_footwear_color = Color()

# Player Raycast Colliders
var left_collider = false
var right_collider = false
var center_collider = false

# Base Stats
var guile = 1
var mental = 1
var power = 1

# Defense
# Ability to discern surroundings
# Detect lies
# Detect alignment of NPCs
func get_awareness():
	return guile + mental

# Utility
# Ability to Lie
# Initiative / turn frequency in Battle
func get_cunning():
	return guile + power

# Offence
# Use badge powers
# How much damage you do with basic attacks
func get_potency():
	return mental + power

# Adjust the desired facing direction with last_move_direction
func set_face_dir(dir):
	if not has_node("Pivot/Body"):
		return
	if dir == null:
		return
	if dir == FACE_LEFT:
		last_move_direction = Vector2(-1, 0)
		$Pivot/Body.frame = FRAME_LEFT
	elif dir == FACE_RIGHT:
		last_move_direction = Vector2(1, 0)
		$Pivot/Body.frame = FRAME_RIGHT
	elif dir == FACE_UP:
		last_move_direction = Vector2(0, -1)
		$Pivot/Body.frame = FRAME_UP
	elif dir == FACE_DOWN:
		last_move_direction = Vector2(0, 1)
		$Pivot/Body.frame = FRAME_DOWN
	else:
		print("ERROR Face dir invalid: ", dir)
	sync_frames()

# Syncs animation clothing frames
func sync_frames():
	if not $Pivot/Body:
		return
	if $Pivot/Body/Hair.visible:
		$Pivot/Body/Hair.frame = $Pivot/Body.frame
	if $Pivot/Body/Legs.visible:
		$Pivot/Body/Legs.frame = $Pivot/Body.frame
	if $Pivot/Body/Torso.visible:
		$Pivot/Body/Torso.frame = $Pivot/Body.frame
	if $Pivot/Body/Feet.visible:
		$Pivot/Body/Feet.frame = $Pivot/Body.frame

# Updates the body looks based on gender and skintone, etc
func update_body():
	var body_path = BASE_CHAR_IMG_PATH + BODY_PATH + base_gender + "/" + base_skintone + ".png"
	var new_body = load(body_path)
	$Pivot/Body.texture = new_body
	if base_hair:
		$Pivot/Body/Hair.texture = load(BASE_CHAR_IMG_PATH + HAIR_PATH + base_hair + ".png")
		$Pivot/Body/Hair.show()
	else:
		$Pivot/Body/Hair.hide()
	if base_legwear:
		$Pivot/Body/Legs.show()
	else:
		$Pivot/Body/Legs.hide()
	if base_torsowear:
		$Pivot/Body/Torso.texture = load(BASE_CHAR_IMG_PATH + TORSO_PATH + base_gender + "_" + base_torsowear + ".png")
		$Pivot/Body/Torso.show()
	else:
		$Pivot/Body/Torso.hide()
	if base_footwear:
		$Pivot/Body/Feet.texture = load(BASE_CHAR_IMG_PATH + FEET_PATH + base_gender + "_" + base_footwear + ".png")
		$Pivot/Body/Feet.show()
	else:
		$Pivot/Body/Feet.hide()

# Based on the direction of the bumper the bumpee will go at an angle
func calc_bump_direction():
	var toss_direction = input_direction
	if input_direction.y == 1: # UP
		if left_collider:
			if center_collider:
				toss_direction.x = -1
			else:
				toss_direction = Vector2(-1, 0)
		if right_collider:
			if center_collider:
				toss_direction.x = 1
			else:
				toss_direction = Vector2(1, 0)
	elif input_direction.y == -1: # Down
		if left_collider:
			if center_collider:
				toss_direction.x = 1
			else:
				toss_direction = Vector2(1, 0)
		if right_collider:
			if center_collider:
				toss_direction.x = -1
			else:
				toss_direction = Vector2(-1, 0)
	elif input_direction.x == 1: # Right
		if left_collider:
			if center_collider:
				toss_direction.y = -1
			else:
				toss_direction = Vector2(0, -1)
		if right_collider:
			if center_collider:
				toss_direction.y = 1
			else:
				toss_direction = Vector2(0, 1)
	elif input_direction.x == -1: # Left
		if left_collider:
			if center_collider:
				toss_direction.y = 1
			else:
				toss_direction = Vector2(0, 1)
		if right_collider:
			if center_collider:
				toss_direction.y = -1
			else:
				toss_direction = Vector2(0, -1)
	return toss_direction

func bump_obj(obj):
	obj.bump_direction = calc_bump_direction()
	obj._change_state(BUMP)

# Get's called when bumped into an obj
func bump_toast():
	$Dialog.toast_msg(bump_messages[randi() % bump_messages.size() ])

func _ready():
	_change_state(IDLE)
	set_face_dir(face_dir)

func play_walk_animation():
	if input_direction == last_move_direction:
		return
	if not input_direction.y:
		if input_direction.x == -1:
			$AnimationPlayer.play('walk_left')
		elif input_direction.x == 1:
			$AnimationPlayer.play('walk_right')
	else:
		if input_direction.y == 1:
			$AnimationPlayer.play('walk_down')
		elif input_direction.y == -1:
			$AnimationPlayer.play('walk_up')

# Handles state changes
func _change_state(new_state):
	match new_state:
		BUSY:
			speed = 0
			$AnimationPlayer.stop()
		IDLE:
			input_direction = Vector2()
			speed = 0
			$AnimationPlayer.stop()
			if last_move_direction.x == -1:
				$Pivot/Body.frame = FRAME_LEFT
			elif last_move_direction.x == 1:
				$Pivot/Body.frame = FRAME_RIGHT
			elif last_move_direction.y == -1:
				$Pivot/Body.frame = FRAME_UP
			elif last_move_direction.y == 1:
				$Pivot/Body.frame == FRAME_DOWN
			last_move_direction = Vector2()
		MOVE:
			play_walk_animation()
			last_move_direction = input_direction
		BUMP:
			$AnimationPlayer.stop()
			max_speed = BUMP_SPEED
			input_direction = bump_direction
			$Timer.set("wait_time", BUMP_DURATION)
			$Timer.start()
	state = new_state
	emit_signal('script_changed', new_state)

func _physics_process(delta):
	if state == IDLE and input_direction:
		_change_state(MOVE)
	elif state == MOVE:
		if not input_direction:
			_change_state(IDLE)
		if input_direction != last_move_direction:
			update_direction()
		var collision_info = move(delta)
		if collision_info:
			var collider = collision_info.collider
			if max_speed == MAX_RUN_SEED and collider.is_in_group('bumpable'):
				bump_obj(collider)
	elif state == BUMP:
		var collision_info = move(delta)
		if collision_info:
			bump_toast()

func update_direction():
	play_walk_animation()
	last_move_direction = input_direction

func move(delta):
	if speed != max_speed:
		speed = max_speed
	else:
		speed = 0
	var motion = input_direction.normalized() * speed * delta
	return move_and_collide(motion)

# Syncs hair, clothing etc frames to body movement
func _on_Body_frame_changed():
	sync_frames()

func _on_Timer_timeout():
	_change_state(IDLE)
