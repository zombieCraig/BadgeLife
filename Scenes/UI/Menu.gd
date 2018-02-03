extends "res://Scenes/UI/Panel.gd"

signal item_selected
signal item_highlighed
signal left_pressed
signal right_pressed

const ITEM_ENTRY_PADDING = 10
const ARROW_IMAGE = "res://ArtSketeches/MenuArrow.png"

# Used to keep a cord during resize
enum { TACT_TOP, TACT_BOTTOM, TACT_LEFT, TACT_RIGHT }

var disable_input = false
var total_items = 0
var focused_item = -1
var item_height = -1
var orig_loc = Vector2() # Original placement of Menu

# checks to see if any item is focused
func has_focus():
	if focused_item == -1:
		return false
	return true

# Selects the next item in the list, scrolls back to top at end
func next_item():
	if focused_item > -1:
		get_focused_item_obj().get_child(0).hide()
	focused_item += 1
	if focused_item >= total_items:
		focused_item = 0
	set_focus(focused_item)

# Selects the prev item
func prev_item():
	if focused_item > -1:
		get_focused_item_obj().get_child(0).hide()
	focused_item -= 1
	if focused_item < 0:
		focused_item = total_items - 1
	set_focus(focused_item)

# Selects the highlighted item
func select_item():
	emit_signal("item_selected", get_focused_item())

# Returns the text of the selected object
func get_focused_item():
	return get_item_obj(focused_item).text

# Returns the selected raw object
func get_focused_item_obj():
	return get_item_obj(focused_item)

# Returns the raw item at index
func get_item_obj(index):
	if index < 0 and index >= total_items:
		return null
	return $VBox.get_child(index)

# sets focus on an item and enables arrow
func set_focus(index):
	if index < 0 and index >= total_items:
		return
	$VBox.get_child(index).get_child(0).show()
	emit_signal("item_highlighed", $VBox.get_child(index).text)
	focused_item = index

# Sets focus based on the item name (text)
func set_focus_by_name(item_name):
	var index = 0
	var found_item = -1
	for item in $VBox.get_children():
		if item.text == item_name:
			found_item = index
			break
		index += 1
	if found_item == -1:
		print("Couldn't find item in menu: ", item_name)
		next_item()
	else:
		set_focus(found_item)

# Cycles through all items and ensures all arrows are disabled
func clear_focus():
	focused_item = -1
	for item in $VBox.get_children():
		item.get_child(0).hide()

# Clears focus and clears up the memory and hides the panel
func destroy_menu():
	clear_focus()
	for item in $VBox.get_children():
		item.get_child(0).free()
		item.free()
	total_items = 0
	panel_hide()

# Resizes the panel box.  To be used after adding items
func resize(tact_loc = TACT_TOP):
	set("rect_size", Vector2(panel_size.x, item_height * total_items + (total_items * (2 * ITEM_ENTRY_PADDING))))
	var diff_size = panel_size - get("rect_size")
	panel_size = get("rect_size")  # Update panel size to the new 'normal' expanded size
	if tact_loc == TACT_BOTTOM:
		set("rect_position", Vector2(orig_loc.x, orig_loc.y +  diff_size.y))
		orig_loc = get("rect_position") # Set new location as standard

func add_item(item_name):
	var item = Label.new()
	var arrow = Sprite.new()
	$VBox.add_child(item)
	item.text = item_name
#	item.set("align", HALIGN_CENTER)
	item.set("valign", VALIGN_CENTER)
	item_height = item.get_line_height()+item.get_constant("line_spacing")
	item.set("rect_min_size", Vector2(0, item_height+ITEM_ENTRY_PADDING))
	item.add_child(arrow)
	arrow.texture = load(ARROW_IMAGE)
	arrow.set("position", Vector2(-20, item_height/2+4))
	arrow.hide()
	total_items += 1

func _input(event):
	if not disable_input:
		if has_focus():
			if Input.is_action_pressed("interact"):
				select_item()
				accept_event()
			elif Input.is_action_pressed("move_down"):
				next_item()
				accept_event()
			elif Input.is_action_pressed("move_up"):
				prev_item()
				accept_event()
			elif Input.is_action_pressed("move_left"):
				emit_signal("left_pressed")
				accept_event()
			elif Input.is_action_pressed("move_right"):
				emit_signal("right_pressed")
				accept_event()

func _ready():
	orig_loc = get("rect_position")