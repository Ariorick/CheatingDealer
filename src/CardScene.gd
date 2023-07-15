extends MarginContainer


var card: Card
var interactable = false


var mouse_in = false
var dragged = false
var drag_mouse_start_pos: Vector2
var drag_start_pos: Vector2
var table # var for table to set itself
var start_pos: Vector2

onready var dealer_position = Vector2(0, get_viewport().size.y + 200)

func _ready():
	modulate = Color.transparent
	if !interactable:
		mouse_filter = MOUSE_FILTER_IGNORE
	$AnimatedSprite.frame = (card.index + 2) + (card.suit_index * 15)
	enter_scene()

func highlight(positive: bool):
	if positive: 
		change_scale(1.2)
		modulate = Color.white
	else:
		var grey = 0.7
		modulate = Color(grey, grey, grey)
		change_scale(0.9)

func neutralize():
	change_scale(1.0)
	modulate = Color.white

func _process(delta):
	if dragged == true:
		rect_global_position = drag_start_pos + get_global_mouse_position() - drag_mouse_start_pos

func _gui_input(event):
	if event is InputEventMouseButton and event.doubleclick and interactable:
		var table = get_parent().get_parent().find_node("TableArea")
		if table != null:
			table.add_card(card)
			queue_free()
	if event.is_action_pressed("mouse_click") and mouse_in:
		dragged = true
		drag_mouse_start_pos = get_global_mouse_position()
		drag_start_pos = rect_global_position
	if event.is_action_released("mouse_click") and dragged:
		if table != null:
			table.add_card(card)
			queue_free()
		else:
			dragged = false
			rect_global_position = drag_start_pos

func enter_scene():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	$Tween.remove_all()
	$Tween.interpolate_property($AnimatedSprite, "global_position", 
		dealer_position, $AnimatedSprite.global_position, 
		0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($AnimatedSprite, "rotation_degrees", 180, 0, 
		0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield(get_tree(), "idle_frame")
	modulate = Color.white

func exit_scene():
	$Tween.remove_all()
	$Tween.interpolate_property($AnimatedSprite, "global_position", 
		$AnimatedSprite.global_position, dealer_position,
		0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($AnimatedSprite, "rotation_degrees", 0, 180, 
		0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()

func _on_Card_mouse_entered():
	mouse_in = true
	change_scale(1.1)

func _on_Card_mouse_exited():
	mouse_in = false
	change_scale(1)

func change_scale(scale: float):
	$AnimatedSprite.scale = Vector2.ONE * 0.5 * scale
