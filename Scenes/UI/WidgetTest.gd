extends Node2D

const LOREM_IPSUM = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,"

var selected_player = null
var action_selected = null

func show_tooltip(msg):
	$Tooltip.set_text(msg)
	if not $Tooltip.visible:
		$Tooltip.panel_show()

func update_tooltips(sub_item):
	if sub_item == "Use Deodarant":
		show_tooltip("Sprays Deodarant at the culprit")
	elif sub_item == "CAN Bus attack":
		show_tooltip("Injects CAN packets into vehicle networks")
	else:
		print("DEBUG: no tooltip for ", sub_item)
		if $Tooltip.visible:
			$Tooltip.panel_hide()

func _on_ShowDialogBtn_pressed():
	$Dialog.set_text($Text.text)
	$Dialog.panel_show()
	
func _on_LoremBtn_pressed():
	$Text.text += LOREM_IPSUM

func _on_MenuTestBtn_pressed():
	$Char1.show()
	$Char2.show()
	$CharSelect.add_item("Bob")
	$CharSelect.add_item("Rick")
	$CharSelect.panel_show()
	$ActionMenu.add_item("Attack")
	$ActionMenu.add_item("Items")
	$ActionMenu.add_item("Skip Turn")
	$ActionMenu.add_item("Flee")
	$ActionMenu.resize($ActionMenu.TACT_BOTTOM)
	$ActionMenu.panel_show()
	$CharSelect.next_item()

func _on_StopMenuTestBtn_pressed():
	$SubActionMenu.destroy_menu()
	$ActionMenu.destroy_menu()
	$CharSelect.destroy_menu()
	$Char1/Select.hide()
	$Char2/Select.hide()
	$Char1.hide()
	$Char2.hide()

func _on_CharSelect_item_highlighed(player):
	if player == "Bob":
		$Char1/Select.show()
		$Char2/Select.hide()
	else:
		$Char1/Select.hide()
		$Char2/Select.show()

func _on_CharSelect_item_selected(player):
	selected_player = player
	$CharSelect.clear_focus()
	$ActionMenu.next_item()

func _on_ActionMenu_item_selected(action):
	action_selected = action
	if action == "Attack":
		$SubActionMenu.add_item("Use Deodarant")
		$SubActionMenu.add_item("CAN Bus attack")
		$SubActionMenu.resize($SubActionMenu.TACT_BOTTOM)
		$SubActionMenu.panel_show()
		$ActionMenu.clear_focus()
		$SubActionMenu.next_item()
	elif action == "Items":
		$SubActionMenu.add_item("IoT Badge")
		$SubActionMenu.add_item("Red Bull & Vodka")
		$SubActionMenu.add_item("Milkshake")
		$SubActionMenu.resize($SubActionMenu.TACT_BOTTOM)
		$SubActionMenu.panel_show()
		$ActionMenu.clear_focus()
		$SubActionMenu.next_item()
	elif action == "Skip Turn":
		$ActionMenu.clear_focus()
		$CharSelect.next_item()
	elif action == "Flee":
		_on_StopMenuTestBtn_pressed()
	else:
		print("Error Unknown action item selected: ", action)

func _on_ActionMenu_right_pressed():
	_on_ActionMenu_item_selected($ActionMenu.get_focused_item())

func _on_ActionMenu_left_pressed():
	$ActionMenu.clear_focus()
	$CharSelect.set_focus_by_name(selected_player)

func _on_SubActionMenu_item_highlighed(sub_item):
	update_tooltips(sub_item)

func _on_SubActionMenu_item_selected(sub_item):
	pass # replace with function body

func _on_SubActionMenu_left_pressed():
	if $Tooltip.visible:
		$Tooltip.panel_hide()
	$SubActionMenu.destroy_menu()
	$ActionMenu.set_focus_by_name(action_selected)
