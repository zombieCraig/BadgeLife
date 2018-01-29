extends KinematicBody2D

const FRAME_UP = 0
const FRAME_LEFT = 9
const FRAME_DOWN = 18
const FRAME_RIGHT = 27

const MAX_WALK_SPEED = 200
const MAX_RUN_SEED = 300 # A little less than double WALK

var speed = 0.0
var max_speed = 0.0
var velocity = Vector2()

var input_direction = Vector2()
var last_move_direction = Vector2(1, 0)

func _ready():
	pass

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
	
