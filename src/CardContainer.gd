extends HBoxContainer
class_name CardContainer

const CardScene = preload("res://src/CardScene.tscn")

func set_cards(cards: Array):
	for child in get_children():
		yield(WaitUtil.wait(0.08), "completed")
		if is_instance_valid(child):
			child.exit_scene()
	for i in cards.size():
		var card = cards[i]
		if i == 1:
			yield(WaitUtil.wait(0.15), "completed")
			pass
		add_child(create_card(card))

func highligt_cards(cards: Array):
	var card_texts := []
	for card in cards:
		card_texts.append(card.text())
	
	if cards.empty():
		for child in get_children():
			child.neutralize()
	else:
		for child in get_children():
			child.highlight(card_texts.has(child.card.text()))
	
	
func create_card(card: Card):
	var card_scene = CardScene.instance()
	card_scene.card = card 
	return card_scene
