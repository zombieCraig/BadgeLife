tool
extends KinematicBody2D

const FRAME_UP = 104
const FRAME_LEFT = 117
const FRAME_DOWN = 130
const FRAME_RIGHT = 143

const MAX_WALK_SPEED = 150
const MAX_RUN_SEED = 200 # A little less than double WALK

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

func _ready():
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

func _physics_process(delta):
	if input_direction:
		if speed != max_speed:
			speed = max_speed
		play_walk_animation()
		last_move_direction = input_direction
	else:
		speed = 0.0
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
		return
	
	# Normalizing even though in 4 dir it's not need, but just in case
#	velocity = input_direction.normalized() * speed
#	move_and_slide(velocity)
	var motion = input_direction.normalized() * speed * delta
	move_and_collide(motion)
	

# Syncs hair, clothing etc frames to body movement
func _on_Body_frame_changed():
	sync_frames()