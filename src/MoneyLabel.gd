extends Label
class_name Moneylabel

var tween: Tween = Tween.new()
var value = 0

export(String) var start_text = ""
export(bool) var hide_when_zero = true

func _ready():
	add_child(tween)

func set_dollars(new_value: int):
	tween.stop_all()
	tween.remove_all()
	rect_scale = Vector2.ONE
	if abs(new_value -value) > 1 && new_value != 0:
		tween.interpolate_method(self, "update_value", value, new_value, 0.4)
		if new_value > value:
			tween.interpolate_property(self, "rect_scale", rect_scale, 
				Vector2(1.2, 1.2), 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween.interpolate_property(self, "rect_scale", rect_scale, 
				Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN, 0.1)
		else: 
			tween.interpolate_property(self, "rect_scale", rect_scale, 
				Vector2(0.9, 0.9), 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween.interpolate_property(self, "rect_scale", rect_scale, 
				Vector2.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN, 0.1)
		tween.start()
	else: 
		update_value(new_value)

func update_value(new_value):
	value = new_value
	
	if value > 0 || not hide_when_zero:
		text = start_text + str(round(new_value)) + "$"
	else:
		text = ""
