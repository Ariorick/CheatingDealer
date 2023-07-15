extends Resource
class_name Card

var index: int
var number: String
var suit_index: int
var suit: String
var i: int

func _init(index, number, suit_index, suit):
	self.index = index
	self.number = number
	self.suit_index = suit_index
	self.suit = suit
	i = index + 2

func text() -> String:
	return number + ":" + suit

func _to_string():
	return text()
