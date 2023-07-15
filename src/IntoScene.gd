extends TextureRect

var tween: Tween = Tween.new()
var text_tween: Tween = Tween.new()
var end_tween: Tween = Tween.new()

var label: Label
var label2: Label

const speed = 20.0

signal scene_completed

func show_scene():
	if get_children().empty():
		return
	label = get_child(0)
	label.percent_visible = 0.0
	if get_child_count() == 2:
		label2 = get_child(1)
		label2.percent_visible = 0.0
	
	add_child(tween)
	add_child(text_tween)
	add_child(end_tween)
	
	var in_duration = 0.6
	tween.interpolate_property(self, "modulate", Color.transparent, Color.white, 
		in_duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	tween.connect("tween_all_completed", self, "start_text")

func start_text():
	if label2 != null:
		animate_text(label)
		yield(text_tween, "tween_all_completed")
		animate_text(get_child(1))
		yield(text_tween, "tween_all_completed")
		end_scene()
	else :
		animate_text(label)
		text_tween.connect("tween_all_completed", self, "end_scene")

func animate_text(label: Label):
	text_tween.remove_all()
	var time = label.text.length() / speed
	text_tween.interpolate_property(label, "percent_visible", 0, 1.0, 
		time)
	text_tween.start()
	

func end_scene():
	var in_duration = 0.8
	end_tween.interpolate_property(self, "modulate", Color.white, Color.transparent,
		in_duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.4)
	end_tween.start()
	end_tween.connect("tween_all_completed", self, "next_scene")

func next_scene():
	emit_signal("scene_completed")
