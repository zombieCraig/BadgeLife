extends "res://Scenes/Character/NPCs/NPC.gd"

enum TRIGGER_STATES { TRIG_IDLE, TRIG_WALK, TRIG_KICK_HOAX, TRIG_TRAIN_MSG, TRIG_TRAIN }

const GENERAL_WALK_DISTANCE = 8  # Approx/close enough walk to amount
const GENERAL_DISTRACE_FROM_DEST = 20 # How close to get

var Manager = null
var walk_path = []
var trigger_state = TRIG_IDLE

var msg1 = "H0ax, you haven't learned a thing.  Get out of here before I make you sorry!"
var msg2 = "Sorry about that, I see you are new here.  Let me show you how to get around"

func change_trigger_state(new_tstate):
	print("DEBUG: Mr. S new trigger state: ", new_tstate)
	match new_tstate:
		TRIG_WALK:
			busy = true
			global.block_player_input = true
			var goto_point = Manager.get_object("mr_sGoto")
			walk_path = Manager.get_navigation_path(position, goto_point.position)
			print("DEBUG: walk_path=",walk_path, " goto_point=",goto_point.position, " position=", position)
		TRIG_IDLE:
			busy = false
			global.block_player_input = false
		TRIG_KICK_HOAX:
			$Dialog.set_text(msg1)
			$Dialog.panel_show()
		TRIG_TRAIN_MSG:
			$Dialog.set_text(msg2)
			$Dialog.panel_show()
		TRIG_TRAIN:
			print("TODO: Finsih later")
			busy = false
			global.block_player_input = false
			Manager.cutscene_stop()
			pass
	trigger_state = new_tstate

func _physics_process(delta):
	if trigger_state == TRIG_WALK:
		if walk_path and walk_path.size() > 1:
			max_speed = MAX_WALK_SPEED
			var pfrom = walk_path[walk_path.size() - 1]
			var pto = walk_path[walk_path.size() - 2]
			var distance = position.distance_to(pto)
			if distance <= GENERAL_DISTRACE_FROM_DEST:
				input_direction = Vector2()
				walk_path.remove(walk_path.size() - 1)
				change_trigger_state(TRIG_KICK_HOAX)
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


func h0ax_trigger():
	change_trigger_state(TRIG_WALK)

func _init_look():
	base_gender = "male"
	base_skintone = "light"
	base_torsowear_color = Color(0.90, 0.90, 0.06)
	base_legwear_color = Color(0.90, 0.90, 0.06)
	base_footwear_color = Color(0.90,0.90,0.06)
	update_body()

func _ready():
	_init_look()
	msg = "You must find your own path"
	npc_name = "Mr. S"
	idle_movement = false
	$IdleTimer.stop()
	if has_node("/root/CampaignManager"):
		Manager = get_node("/root/CampaignManager")
	else:
		print("Couldn't locate CampaignManager")

func _on_Dialog_dialog_completed():
	match trigger_state:
		TRIG_KICK_HOAX:
			var h0ax = Manager.get_npc_by_name("h0ax")
			if h0ax:
				h0ax.run_away_trigger()
				change_trigger_state(TRIG_TRAIN_MSG)
			else:
				print_error("Mr S. error: H0ax could not be located")
		TRIG_TRAIN_MSG:
			change_trigger_state(TRIG_TRAIN)
		TRIG_IDLE:
			global.block_player_input = false
			busy = false