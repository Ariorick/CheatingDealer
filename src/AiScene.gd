extends Node2D
class_name AiScene

const CardScene = preload("res://src/CardScene.tscn")

export(NodePath) onready var sprite = get_node(sprite) as Sprite

func _ready():
	set_cards([])
	set_bet(0)
	sprite.material = sprite.material.duplicate()
	sprite.material.set_shader_param("frame_offset", Random.i_range(0, 50))
	sprite.material.set_shader_param("speed", Random.f_range(1.3, 2.0) * 8)
	sprite.material.set_shader_param("frames", 80)

func turn(on: bool, win: bool = false):
	sprite.alternate(on, win)

func set_money(money: int):
	$Money.set_dollars(money)


func highligt_cards(cards: Array):
	$CardsContainer.highligt_cards(cards)

func set_cards(cards: Array):
	$CardsContainer.set_cards(cards)

func set_bet(bet: int):
	$Bet.set_dollars(bet)

func create_card(card: Card):
	var card_scene = CardScene.instance()
	card_scene.card = card 
	return card_scene

