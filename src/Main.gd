extends Node2D

onready var tween: Tween = $Intro/Tween

func _ready():
	$Intro/Scene1.modulate = Color.transparent
	$Intro/Scene2.modulate = Color.transparent
	$Intro/Scene3.modulate = Color.transparent
	$Intro/Scene4.modulate = Color.transparent
	$Intro/Scene1.show()
	$Intro/Scene2.show()
	$Intro/Scene3.show()
	$Intro/Scene4.show()
	$Intro/Scene1.show_scene()


func _on_Scene1_scene_completed():
	$Intro/Scene2.show_scene()


func _on_Scene2_scene_completed():
	$Intro/Scene3.show_scene()


func _on_Scene3_scene_completed():
	$Intro/Scene4.show_scene()


func _on_Scene4_scene_completed():
	var in_duration = 1.0
	tween.interpolate_property($Intro, "modulate", Color.white, Color.transparent, 
		in_duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
#	tween.interpolate_property($Game, "modulate", Color.transparent, Color.white, 
#		in_duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	tween.connect("tween_all_completed", self, "start_game")

func start_game():
	$Intro.visible = false
	$Intro.queue_free()
	$Game.full_restart()


func _on_SkipButton_pressed():
	start_game()
