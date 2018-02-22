extends NinePatchRect

export var animation_speed = 0.3
var animate = true

# Used to keep a cord during resize
enum { TACT_TOP, TACT_BOTTOM, TACT_LEFT, TACT_RIGHT }

var panel_size = Vector2(162, 66)

# If the panel is animating (on show) set to true
var panel_animating = false
var closing = false

func panel_show():
	# If panel was closing, interrupt and re-open
	if $Tween.is_active():
		$Tween.stop_all()
		$Tween.remove_all()
	$Tween.interpolate_property(self, "rect_size", Vector2(panel_size.x, 20), panel_size, animation_speed, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
	show()
	panel_animating = true
	closing = false

func panel_hide():
	if $Tween.is_active():
		$Tween.stop_all()
		$Tween.remove_all()
	$Tween.interpolate_property(self, "rect_size", panel_size, Vector2(panel_size.x, 20), animation_speed, Tween.TRANS_ELASTIC, Tween.EASE_IN)
	$Tween.start()
	panel_animating = true
	closing = true

func _ready():
	panel_size = rect_size

func _on_Tween_tween_completed( object, key ):
	$Tween.remove_all()
	panel_animating = false
	if closing:
		hide()
