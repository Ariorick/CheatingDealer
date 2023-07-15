extends Area2D

func add_card(card: Card):
	get_parent().add_card_to_table(card)

func _on_TableArea_area_entered(area):
	var card_scene = area.get_parent()
	card_scene.table = self


func _on_TableArea_area_exited(area):
	var card_scene = area.get_parent()
	card_scene.table = null
