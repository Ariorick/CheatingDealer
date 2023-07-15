extends Resource
class_name Result

var owner_id: int
var hand_card_result: Array # of Cards
var bank_card_result: Array # of Cards
var rank: String
var result: Array


func _init(hand_card_result, bank_card_result, rank, result):
	self.hand_card_result = hand_card_result
	self.bank_card_result = bank_card_result
	self.rank = rank
	self.result = result

func _to_string():
	return "(" + owner() + ", " + rank + ", " + str(hand_card_result) + " " + str(bank_card_result) + ")"

func owner() -> String:
	match(owner_id):
		-1:
			return "Lil Jimmy"
		0:
			return "Scary Bob"
		1:
			return "Miss Kitty"
		2:
			return "Fanny Fox"
	return ""
