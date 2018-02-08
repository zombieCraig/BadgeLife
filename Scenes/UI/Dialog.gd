extends "res://Scenes/UI/Panel.gd"

signal dialog_completed

var original_text = ""
var buf = ""
var max_lines = 1
export var disable_input = false # Turn off input handler
var buffer_complete = false
var buf_index = 0
var buffer_beginning = true
var buffer_paused = false

# A toast message is a short message with input disabled.  It is displayed for a
# short time then hides.  Unlick set_text this will also animate the show and hide
# of the panel
func toast_msg(msg, timeout=1.0):
	disable_input = true
	if not visible:
		panel_show()
	set_text(msg)
	$Timer.set("wait_time", timeout)
	$Timer.start()

# Parses the buffer for substitutions
func parse_buf():
	buf = buf.replace("\n", "\n ") # Add a space for 'pause' parsing
	buf = buf.replace("$name", global.player["name"])

# Calculate how many lines will fit in our panel
func calc_max_lines():
	max_lines = floor(get_size().y/($Text.get_line_height()+$Text.get_constant("line_spacing")))

# Adds a word and upates the buffer.
# Returns false if we are done and have no more to print
# Else if there are words left or it is paused we return true
func add_next_word():
	if buf.length() == 0:
		buffer_complete = true
		return
	var index = buf.find(" ", buf_index)
	if index == -1:
		buffer_complete = true
		if buffer_beginning:
			$Text.text += buf.substr(buf_index, buf.length() - buf_index)
		else:
			$Text.text += buf.substr(buf_index-1, buf.length() - buf_index+1)
		return false
	var temp_text = $Text.text
	if buffer_beginning:
		buffer_beginning = false
		var next_chunk = buf.substr(buf_index, index - buf_index + 1)
		var cr_index = next_chunk.find('\n')
		if cr_index == -1: # No \n
			$Text.text += next_chunk
		else: # convert \n to pause
			$Text.text += next_chunk.substr(0, cr_index)
			buf_index += cr_index + 2
			pause_buffer()
			return true
	else:
		# Need to check for \n
		var next_chunk = buf.substr(buf_index-1, index - buf_index + 1)
		var cr_index = next_chunk.find('\n')
		if cr_index == -1: # No \n
			$Text.text += next_chunk
		else: # convert \n to pause
			$Text.text += next_chunk.substr(0, cr_index)
			buf_index += cr_index + 1
			pause_buffer()
			return true
	var lines = $Text.get_line_count()
	if lines == max_lines:
		if max_lines == 1: # This can sometimes happen if the dialog is too small but looks OK
			if lines > 1:
				$Text.text = temp_text # Roll back the last word add
				pause_buffer()
			else:
				buf_index = index + 1
		else:
			$Text.text = temp_text # Roll back the last word add
			pause_buffer()
	else:
		buf_index = index + 1
	return true

# Actual function that converts the buffer to the label text
func prepare_buf():
	parse_buf()
	calc_max_lines()

# Pauses the buffer and flashes the arrow
func pause_buffer():
	if disable_input:
		return
	buffer_paused = true
	$MarginContainer/DialogArrow.show()
	$AnimationPlayer.play("ArrowBounce")

# Sets up buff to continue on the the next page of text
func next_buffer_page():
	clear_text()
	buffer_paused = false
	$MarginContainer/DialogArrow.hide()
	$AnimationPlayer.play("INIT")

# Main external function for setting dialog text
func set_text(msg):
	reset()
	original_text = msg
	buf = msg
	buffer_complete = false
	prepare_buf()

func clear_text():
	$Text.text = ""

func clear_buffer():
	buf = ""
	buf_index =  0
	buffer_beginning = true
	buffer_paused = false

func reset():
	clear_text()
	clear_buffer()
	$MarginContainer/DialogArrow.hide()

func _input(event):
	if not visible:
		return
	if not disable_input:
		if buf.length() > 0:
			if buffer_paused:
				if Input.is_action_pressed("interact"):
					next_buffer_page()
					accept_event()
			if buffer_complete and not panel_animating:
				if Input.is_action_pressed("interact"):
					accept_event()
					emit_signal("dialog_completed")
					panel_hide()

func _process(delta):
	if not buffer_complete:
		if not panel_animating:
			if not buffer_paused:
				add_next_word()

func _ready():
	reset()

func _on_Timer_timeout():
	if visible:
		panel_hide()
