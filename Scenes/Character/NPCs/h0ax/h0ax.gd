extends "res://Scenes/Character/NPCs/NPC.gd"

var triggered = false
var Manager = null
var walk_path = []
var trigger_state
var runto_dest = Vector2()

const GENERAL_WALK_DISTANCE = 8  # Approx/close enough walk to amount
const GENERAL_DISTRACE_FROM_DEST = 20 # How close to get

enum TRIGGER_STATES { TRIG_WALK, TRIG_TALK, TRIG_MR_S, TRIG_RUN_AWAY, TRIG_IDLE }

var msg1 = "Hey, who are you?  I don't know you.  You are not l33t enough to be here!"
var msg2 = "Fine, whatever.  $name, you will always suck"

func change_trigger_state(new_tstate):
	print("DEBUG H0ax new trig state: ", new_tstate)
	match new_tstate:
		TRIG_WALK:
			busy = true
			global.block_player_input = true
			Manager.cutscene_start()
		TRIG_IDLE:
			busy = false
		TRIG_TALK:
			$Dialog.set_text(msg1)
			$Dialog.panel_show()
		TRIG_RUN_AWAY:
			walk_path = Manager.get_navigation_path(position, runto_dest)
	trigger_state = new_tstate


# Called by Mr. S.
func run_away_trigger():
	change_trigger_state(TRIG_RUN_AWAY)

func _physics_process(delta):
	if trigger_state == TRIG_WALK or trigger_state == TRIG_RUN_AWAY:
		if walk_path and walk_path.size() > 1:
			max_speed = MAX_WALK_SPEED
			var pfrom = walk_path[walk_path.size() - 1]
			var pto = walk_path[walk_path.size() - 2]
			var distance = position.distance_to(pto)
	#		print("DEBUG: distnace=",distance)
			if distance <= GENERAL_DISTRACE_FROM_DEST:
				input_direction = Vector2()
				walk_path.remove(walk_path.size() - 1)
				if trigger_state == TRIG_WALK:
					change_trigger_state(TRIG_TALK)
				else:
					change_trigger_state(TRIG_IDLE)
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

func _triggered(triggered_by, trigger_obj):
	if triggered:
		return
	if trigger_obj.has_meta("goto"):
		var goto_point = trigger_obj.get_meta("goto")
		var goto_obj = Manager.get_object(goto_point)
		if goto_obj:
			if triggered_by.get('name') == 'Player':
				var runto_point = trigger_obj.get_meta("runto")
				runto_dest = Manager.get_object(runto_point).position
				walk_path = Manager.get_navigation_path(position, goto_obj.position)
				change_trigger_state(TRIG_WALK)
				triggered = true

func _init_look():
	randomize_look()

func _ready():
	_init_look()
	npc_name="h0ax"
	msg = "Whaterver $name, just bugger off"
	idle_movement = false
	$IdleTimer.stop()
	if has_node("/root/CampaignManager"):
		Manager = get_node("/root/CampaignManager")
	else:
		print("Couldn't locate CampaignManager")

func _on_Dialog_dialog_completed():
	match trigger_state:
		TRIG_TALK:
			var mr_s = Manager.get_npc_by_name("Mr. S")
			if mr_s:
				mr_s.h0ax_trigger()
			else:
				print("h0ax error: Mr. S could not be located")
		TRIG_IDLE:
			global.block_player_input = false
			busy = false