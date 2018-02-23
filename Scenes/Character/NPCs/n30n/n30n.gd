extends "res://Scenes/Character/NPCs/NPC.gd"

const GENERAL_WALK_DISTANCE = 8  # Approx/close enough walk to amount
const GENERAL_DISTRACE_FROM_DEST = 20 # How close to get

var walking_to_target = false
var walk_path = []
var Manager = false
enum TRIGGER_STATES { TRIG_IDLE, TRIG_WALK, TRIG_NAME_PROMPT, TRIG_GIVE_BADGE, TRIG_BYE_MSG }
var trigger_state = TRIG_IDLE
var triggered = false

var msg1 = "Hello, I'm n30n.  Welcome to PrimeCon.  I'll get your badge for you, what name did you register under?"
# Get name
var msg2 = "$name, eh? Ok, let me check the registration...\nHmmmn,\nUhm,\nOh wait, there you are!\nHere's your PrimeCon badge."
# Give Badge
var msg3 = "Be sure to check out the vendor booths too!"

func init_look():
	base_gender = "female"
	base_hair = "bangs"
	base_hair_color = Color(0.85, 0.06, 0.92)
	_random_skintone()
	base_torsowear_color = Color(0.92, 0.06, 0.06)
	base_footwear_color = Color(0.59,0.87,0.86)
	update_body()

func give_primecon_badge():
	print("TODO: Give Item")
	change_trigger_state(TRIG_BYE_MSG)

func change_trigger_state(new_tstate):
	match new_tstate:
		TRIG_WALK:
			busy = true
			global.block_player_input = true
			Manager.cutscene_start()
		TRIG_IDLE:
			busy = false
			global.block_player_input = false
		TRIG_NAME_PROMPT:
			$NameInput.set_text(msg1, "Name")
			$NameInput.panel_show()
			$NameInput/InputArea/TextEdit.grab_focus()
		TRIG_GIVE_BADGE:
			$Dialog.set_text(msg2)
			$Dialog.panel_show()
		TRIG_BYE_MSG:
			$Dialog.set_text(msg3)
			$Dialog.panel_show()
	trigger_state = new_tstate


func _physics_process(delta):
	if trigger_state == TRIG_WALK:
		if walk_path and walk_path.size() > 1:
			max_speed = MAX_WALK_SPEED
			var pfrom = walk_path[walk_path.size() - 1]
			var pto = walk_path[walk_path.size() - 2]
			var distance = position.distance_to(pto)
	#		print("DEBUG: distnace=",distance)
			if distance <= GENERAL_DISTRACE_FROM_DEST:
				input_direction = Vector2()
				walk_path.remove(walk_path.size() - 1)
				change_trigger_state(TRIG_NAME_PROMPT)
			else:
				if int(position.x) > int(pto.x) + GENERAL_WALK_DISTANCE:
					input_direction = Vector2(-1, 0)
				elif int(position.x) < int(pto.x) - GENERAL_WALK_DISTANCE:
					input_direction = Vector2(1, 0)
				elif int(position.y) > int(pto.y) + GENERAL_WALK_DISTANCE:
					input_direction = Vector2(0, -1)
				elif int(position.y) < int(pto.y) - GENERAL_WALK_DISTANCE:
					input_direction = Vector2(0, 1)
				else:
					input_direction = Vector2()
					print("on top done")

# Initial trigger should have an extra meta tag "goto" with the location object to walk to
func _triggered(triggered_by, trigger_obj):
	if triggered:
		return
	if trigger_obj.has_meta("goto"):
		var goto_point = trigger_obj.get_meta("goto")
		var goto_obj = Manager.get_object(goto_point)
		if goto_obj:
			if triggered_by.get('name') == 'Player':
				walk_path = Manager.get_navigation_path(position, goto_obj.position)
				change_trigger_state(TRIG_WALK)
				triggered = true

func _ready():
	npc_name = "n30n"
	# General interact messsage
	msg = "Hey $name, I hope to see you at more conferences soon"
	init_look()
	idle_movement = false
	$IdleTimer.stop()
	if has_node("/root/CampaignManager"):
		Manager = get_node("/root/CampaignManager")
	else:
		print("Couldn't locate CampaignManager")

func _on_NameInput_input_entered(player_name):
	$NameInput.panel_hide()
	global.player["name"] = player_name
	change_trigger_state(TRIG_GIVE_BADGE)

func _on_Dialog_dialog_completed():
	match trigger_state:
		TRIG_GIVE_BADGE:
			give_primecon_badge()
		TRIG_BYE_MSG:
			change_trigger_state(TRIG_IDLE)
			Manager.cutscene_stop()
			idle_movement = true
			set_idle_timer()
		_:
			global.block_player_input = false
			busy = false
