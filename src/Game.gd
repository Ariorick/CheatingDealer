extends Node2D

const CardScene = preload("res://src/CardScene.tscn")
const WAIT = 0.4

const suits := ["H", "T", "C", "S"]
const numbers := ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
const ranks := ["High Card","Pair","Two Pair","Trips","Straight","Flush","Full house","Quads","Straight Flush"]

var ai_count := 3
var dealer_max_hand := 5

var deck := []
var bank := 0

var ai_hands := [] # of array of cards
var ai_money := []
var ai_bets = [0,0,0]
var ai_scenes = []

var player_hand := [] # of cards
var player_money := 10
var player_bet := 0

var dealer_hand := []
var bank_hand := []

func _ready():
	set_default_values()
	reset()
	randomize()
	
	#FOR TESTING ONLY
#	full_restart()

func set_default_values():
	ai_money = [200, 300, 100]
	player_money = 10
	ai_count = 3
	ai_scenes = [$AiScene, $AiScene2, $AiScene3]

func full_restart():
	set_default_values()
	restart()

func restart():
	reset()
	create_deck_and_start()

func create_deck_and_start():
	# Check for losers
	if player_money <= 0:
		$LoseScreen.show()
		return
	
	var i = 0
	while i < ai_count:
		if ai_money[i] <= 0:
			ai_money.remove(i)
			ai_scenes.remove(i)
			ai_bets.remove(i)
			ai_count -= 1
			i -= 1
		i += 1
	
	if ai_count == 0:
		$WinScreen.show()
		return
	
	for n in numbers.size():
		for s in suits.size():
			deck.append(card(n, s))
	
	deck.shuffle()
	deal_cards()

func reset():
	deck = []
	ai_hands = [] # of array of cards
	ai_bets = [0,0,0]
	
	player_hand = [] # of cards
	player_bet = 0
	
	dealer_hand = []
	bank_hand = []
	
	show_dealer_buttons(false)
	show_player_buttons(false)
	for i in ai_count:
		ai_scenes[i].set_money(ai_money[i])
		ai_scenes[i].set_cards([])
		yield(WaitUtil.wait(0.15), "completed")
	$Player.set_money(player_money)
	$Player.set_cards([])
	NodeUtils.delete_children($BankHand)
	NodeUtils.delete_children($DealerHand)
	
	$Combo.text = ""
	$Bank.set_dollars(bank)

func deal_cards():
	for i in ai_count:
		var ai_hand = [deck.pop_back(), deck.pop_back()]
		ai_hands.append(ai_hand)
		ai_scenes[i].set_cards(ai_hands[i])
		yield(WaitUtil.wait(WAIT),"completed");
		
	
	player_hand = [deck.pop_back(), deck.pop_back()]
	$Player.set_cards(player_hand)
	
	for i in dealer_max_hand - dealer_hand.size():
		add_dealer_card()
	player_turn()

func add_dealer_card():
	var card = deck.pop_back()
	dealer_hand.append(card)
	var card_scene = create_card(card, true)
	$DealerHand.add_child(card_scene)

func create_card(card: Card, interactable: bool):
	var card_scene = CardScene.instance()
	card_scene.card = card 
	card_scene.interactable = interactable
	return card_scene

func add_card_to_table(card: Card):
	dealer_hand.erase(card)
	bank_hand.append(card)
	$BankHand.add_child(create_card(card, false))
	add_dealer_card()
	show_dealer_buttons(true)

func player_turn():
	$Player.turn(true)
	show_player_buttons(true)

func ai_turn(index: int):
	if index == ai_count:
		dealer_turn()
		return
	var scene = ai_scenes[index]
	var money = ai_money[index]
	var bet = min(player_bet, money)
	money = money - bet
	ai_bets[index] = bet
	ai_money[index] = money
	
	scene.turn(true)
	scene.set_bet(bet)
	scene.set_money(money)
	yield(WaitUtil.wait(WAIT*1.5),"completed");
	scene.turn(false)
	ai_turn(index + 1)

func dealer_turn():
	for i in ai_count:
		bank += ai_bets[i]
		ai_bets[i] = 0
		ai_scenes[i].set_bet(0)
		$Bank.set_dollars(bank)
		yield(WaitUtil.wait(WAIT),"completed");
	
	bank += player_bet
	player_bet = 0
	$Player.set_bet(0)
	$Bank.set_dollars(bank)
	yield(WaitUtil.wait(WAIT),"completed");
	
	show_dealer_buttons(true)

func evaluate_hand(hand):
	pass

func _on_BetButton_pressed():
	player_bet = max(round(player_money * 0.05), 1)
	finish_player_turn()

func _on_AllInButton_pressed():
	player_bet = player_money
	finish_player_turn()

func finish_player_turn():
	player_money -= player_bet
	$Player.turn(false)
	$Player.set_money(player_money)
	$Player.set_bet(player_bet)
	show_player_buttons(false)
	ai_turn(0)

func show_player_buttons(show: bool):
	$BetButton.visible = show
	$AllInButton.visible = show
	$WhatShould.visible = show

func show_dealer_buttons(show: bool):
	$Hint.visible = show and bank_hand.size() < 5
	$DealerHand.visible = show && bank_hand.size() < 5
	$NextRoundButton.visible = show && player_money > 0 && bank_hand.size() < 5
	$ShowCardsButton.visible = show && bank_hand.size() > 4


func _on_NextRoundButton_pressed():
	show_dealer_buttons(false)
	player_turn()


func _on_ShowCardsButton_pressed():
	show_dealer_buttons(false)
	show_combinations()

func show_combinations():
	var results := []
	var player_combo := HandComparator.strongest_combo(player_hand, bank_hand, ranks)
	player_combo.owner_id = -1
	results.append(player_combo)
	for i in ai_count:
		var ai_combo = HandComparator.strongest_combo(ai_hands[i], bank_hand, ranks)
		ai_combo.owner_id = i
		results.append(ai_combo)
	
	results.sort_custom(self, "first_result_is_better")
	print(results)
	results.invert()
	
	for i in results.size():
		var result = results[i]
		ai_or_player(result.owner_id).turn(true)
		show_combination(result)
		yield(WaitUtil.wait(WAIT * 4),"completed");
		if i == results.size() - 1:
			show_winner(result)
			ai_or_player(result.owner_id).turn(true, true)
			yield(WaitUtil.wait(WAIT * 3),"completed");
			hide_combination(result)
			
			transfer_money_to_winner(result)
			
			ai_or_player(result.owner_id).turn(false)
			reset()
			yield(WaitUtil.wait(WAIT),"completed");
			create_deck_and_start()
		else:
			hide_combination(result)
			ai_or_player(result.owner_id).turn(false)

func ai_or_player(owner_id: int) -> AiScene:
	if owner_id == -1:
		return $Player as AiScene
	else:
		return ai_scenes[owner_id]

func transfer_money_to_winner(result: Result):
	if result.owner_id == -1:
		player_money += bank
	else:
		ai_money[result.owner_id] += bank
	bank = 0

func show_combination(result: Result):
	ai_or_player(result.owner_id).highligt_cards(result.hand_card_result)
	$BankHand.highligt_cards(result.bank_card_result)
	$Combo.text = result.rank


func hide_combination(result: Result):
	$Combo.text = ""
	ai_or_player(result.owner_id).highligt_cards([])
	$BankHand.highligt_cards([])

func show_winner(result: Result):
	$Combo.text = result.owner() + " WINS!"



func first_result_is_better(first: Result, second: Result) -> bool:
	var first_is_better = HandComparator.firstHandIsBetter(first.result, second.result)
	var second_is_better = HandComparator.firstHandIsBetter(second.result, first.result)
	if (first_is_better and second_is_better):
		if first.owner_id == -1:
			return true
		elif second.owner_id == -1:
			return false
	
	return first_is_better



func card(index: int, suit_index: int) -> Card:
	return Card.new(index, numbers[index], suit_index, suits[suit_index])


func _on_ReplayButton_pressed():
	$LoseScreen.visible = false
	$WinScreen.visible = false
	full_restart()
