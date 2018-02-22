extends "res://Scenes/UI/Panel.gd"

signal input_entered

func set_text(msg, label):
	$Msg.text = msg
	$InputArea/Label.text = label

func process_input():
	if visible:
		if $InputArea/TextEdit.text.length() > 0:
			$InputArea/TextEdit.text = $InputArea/TextEdit.text.replace('\n','')
			$InputArea/TextEdit.text = $InputArea/TextEdit.text.strip_edges()
			emit_signal('input_entered', $InputArea/TextEdit.text)

func _input(event):
	if event.is_action_pressed('ui_accept'):
		process_input()
		accept_event()

func _ready():
	$InputArea/TextEdit.grab_focus()

# Play click sound
func _on_TextEdit_text_changed():
	pass # replace with function body

func _on_OKBtn_pressed():
	process_input()
