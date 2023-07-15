class_name HandComparator

# Written by Tyler Fisher, 20 Feb 2017. For sample boards, see https://goo.gl/19jGRx

static func strongest_combo(hand: Array, bank_hand: Array, ranks: Array) -> Result:
	print("---strongest combo---")
	print("hand")
	print(hand)
	print("bank_hand")
	print(bank_hand)
	
	var cards7: Array = [hand[0].i, hand[1].i] 
	for card in bank_hand:
		cards7.append(card.i)
	
	var suits7: Array = [hand[0].suit_index, hand[1].suit_index] 
	for card in bank_hand:
		suits7.append(card.suit_index)
	
	var result : Array = getBestFrom7(cards7, suits7)
	
	var rank = ranks[result[5]]
	print(rank)
	
	
	var hand_copy = hand.duplicate()
	var bank_copy = bank_hand.duplicate()
	var sorted_result := result.slice(0, 4)
	sorted_result.sort()
	var hand_card_result := []
	var bank_card_result := []
	var bank_result = []
	
#	if rank == "Straight Flush" || rank == "Flush":
#		print("can't handle flush yet")
#		pass
#	else:
	for i in sorted_result.size():
		var index_in_hand = find_card_by_index(hand_copy, sorted_result[i])
		if index_in_hand == -1:
			bank_result.append(sorted_result[i])
		else:
			var card = hand_copy[index_in_hand]
			hand_card_result.append(card)
			hand_copy.remove(index_in_hand)
	
	for i in bank_result.size():
		var index_in_bank = find_card_by_index(bank_copy, bank_result[i])
		var card = bank_copy[index_in_bank]
		bank_copy.remove(index_in_bank)
		bank_card_result.append(card)
	
	
	print("hand_card_result")
	print(hand_card_result)
	print("bank_card_result")
	print(bank_card_result)
	return Result.new(hand_card_result, bank_card_result, rank, result)

# returns index of card with index matching given index or null
static func find_card_by_index(cards: Array, index:int): 
	for i in cards.size():
		if cards[i].i == index:
			return i
	return -1

static func firstHandIsBetter(h1, h2): # given two hands, with the 5 cards + rank + relevant kicker details, say which wins
	if h1[5] != h2[5]: return h1[5] > h2[5] # different ranks
	if h1[5]==8 or h1[5]==4: return h1[2] > h2[2] if h1[2] != h2[2] else null # SF or straight: check middle card
	if h1[5]==5 or h1[5]==0: # flush or high card: check all five cards
		for wooper in range(5):
			if h1[4 - wooper] != h2[4 - wooper]: return h1[4 - wooper] > h2[4 - wooper]
		return null # chop
	for scromp in range(6,10):
		if h1[scromp] != h2[scromp]: return h1[scromp] > h2[scromp] # one is higher, so that one wins
		if len(h1) == scromp+1: return null # all were the same, so it's a chop

static func getBestFrom7(sevenCards: Array, sevenSuits: Array): # given 7 cards, call the 5-card comparator on each of the 21 poss. combos
	var bestHand = null
	for i in range(7):
		for j in range(i+1, 7):
			var s := []
			for k in range(7):
				if k != i and k != j: s.append_array([sevenCards[k], sevenSuits[k]])
			var fC = [s[0],s[2],s[4],s[6],s[8]]
			fC.sort()
			var newHand = getHandRankFromFiveCards(fC, [s[1],s[3],s[5],s[7],s[9]])
			if bestHand == null or firstHandIsBetter(newHand, bestHand): bestHand = newHand
	return bestHand

static func getHandRankFromFiveCards(fC, fS): # given 5 cards, determine what the rank of the hand is and add kicker info to it
	if fS.count(fS[0])==len(fS): fC.append(8) if ( all_equals([fC[0], fC[1]-1, fC[2]-2, fC[3]-3]) and (fC[4]-1==fC[3] or fC[4]-12==fC[0])) else fC.append(5)
	elif (all_equals([fC[0], fC[1]-1, fC[2]-2, fC[3]-3]) and (fC[4]-1 == fC[3] or fC[4]-12 == fC[0])): fC.append(4) # straight
	elif all_equals([fC[1], fC[2], fC[3]]) and (fC[0]==fC[1] or fC[3]==fC[4]): fC.append_array([7, fC[0], fC[4]]) if fC[0]==fC[1] else fC.append_array([7, fC[4], fC[0]]) # quads
	elif all_equals([fC[0], fC[1], fC[2]]) and fC[3]==fC[4]: fC.append_array([6, fC[0], fC[4]]) # boat, high set full of low pair
	elif fC[0] == fC[1] and all_equals([fC[2], fC[3], fC[4]]): fC.append_array([6, fC[4], fC[0]]) # boat, low set full of high pair
	elif all_equals([fC[0], fC[1], fC[2]]): fC.append_array([3, fC[0], fC[4], fC[3]]) # trips, both kickers higher; other kicker-types of trips in next line
	elif fC[2]==fC[3] and (fC[1]==fC[2] or fC[3]==fC[4]): fC.append_array([3, fC[1], fC[4], fC[0]]) if fC[1]==fC[2] else fC.append_array([3, fC[2], fC[1], fC[0]])
	elif (fC[0]==fC[1] and (fC[2]==fC[3] or fC[3]==fC[4])) or (fC[1]==fC[2] and fC[3]==fC[4]): # two pair
		if fC[0]==fC[1] and fC[2]==fC[3]: fC.append_array([2, fC[3], fC[1], fC[4]]) # kicker higher than both pairs
		else: fC.append_array([2, fC[4], fC[1], fC[2]]) if fC[0]==fC[1] and fC[3]==fC[4] else fC.append_array([2,fC[4],fC[1],fC[0]])
	elif fC[0]==fC[1] or fC[1]==fC[2]: fC.append_array([1, fC[0], fC[4], fC[3], fC[2]]) if fC[0]==fC[1] else fC.append_array([1, fC[1], fC[4], fC[3], fC[0]])
	elif fC[2]==fC[3] or fC[3]==fC[4]: fC.append_array([1, fC[2], fC[4], fC[1], fC[0]]) if fC[2]==fC[3] else fC.append_array([1, fC[3], fC[2], fC[1], fC[0]])
	return fC if len(fC) > 5 else fC + [0] # return hand, but first if we haven't appended anything else note that it's just a high card hand

#static func getHandRankFromFiveCards(fC, fS): # given 5 cards, determine what the rank of the hand is and add kicker info to it
#	if fS.count(fS[0])==len(fS): fC.append(8) if ((fC[0]==fC[1]-1==fC[2]-2==fC[3]-3) and (fC[4]-1==fC[3] or fC[4]-12==fC[0])) else fC.append(5)
#	elif ((fC[0] == fC[1]-1 == fC[2]-2 == fC[3]-3) and (fC[4]-1 == fC[3] or fC[4]-12 == fC[0])): fC.append(4) # straight
#	elif fC[1]==fC[2]==fC[3] and (fC[0]==fC[1] or fC[3]==fC[4]): fC.append_array([7, fC[0], fC[4]]) if fC[0]==fC[1] else fC.append_array([7, fC[4], fC[0]]) # quads
#	elif fC[0]==fC[1]==fC[2] and fC[3]==fC[4]: fC.append_array([6, fC[0], fC[4]]) # boat, high set full of low pair
#	elif fC[0] == fC[1] and fC[2] == fC[3] == fC[4]: fC.append_array([6, fC[4], fC[0]]) # boat, low set full of high pair
#	elif fC[0]==fC[1]==fC[2]: fC.append_array([3, fC[0], fC[4], fC[3]]) # trips, both kickers higher; other kicker-types of trips in next line
#	elif fC[2]==fC[3] and (fC[1]==fC[2] or fC[3]==fC[4]): fC.append_array([3, fC[1], fC[4], fC[0]]) if fC[1]==fC[2] else fC.append_array([3, fC[2], fC[1], fC[0]])
#	elif (fC[0]==fC[1] and (fC[2]==fC[3] or fC[3]==fC[4])) or (fC[1]==fC[2] and fC[3]==fC[4]): # two pair
#		if fC[0]==fC[1] and fC[2]==fC[3]: fC.append_array([2, fC[3], fC[1], fC[4]]) # kicker higher than both pairs
#		else: fC.append_array([2, fC[4], fC[1], fC[2]]) if fC[0]==fC[1] and fC[3]==fC[4] else fC.append_array([2,fC[4],fC[1],fC[0]])
#	elif fC[0]==fC[1] or fC[1]==fC[2]: fC.append_array([1, fC[0], fC[4], fC[3], fC[2]]) if fC[0]==fC[1] else fC.append_array([1, fC[1], fC[4], fC[3], fC[0]])
#	elif fC[2]==fC[3] or fC[3]==fC[4]: fC.append_array([1, fC[2], fC[4], fC[1], fC[0]]) if fC[2]==fC[3] else fC.append_array([1, fC[3], fC[2], fC[1], fC[0]])
#	return fC if len(fC) > 5 else fC + [0] # return hand, but first if we haven't appended anything else note that it's just a high card hand

static func all_equals(array: Array) -> bool:
	for i in array.size() -1:
		if array[i] != array[i+1]:
			return false
	return true

static func output(p1H: Array):
	var ranks = ["just a high card","one pair","two pair","trips","a straight","a flush","full house","quads","a straight flush"]

	print(ranks[p1H[5]])

	# When it prints out the players' cards, the first five characters are the hand itself, and then it says the hand's rank.
	#  Basically, the first number is the first relevant card, the second number is the second one, etc. More specifically:
		#  If we have a flush or just a high card, we need to check all 5 cards anyway, so we don't need any additional numbers.
		#  If we have one pair, we need all three kickers, so there's the value of the pair + three more kickers
		#  If we have two pair, we have the high pair, then the low pair, then the kicker.
		#  If we have trips, we have the trips card, then the first kicker, then the second kicker.
		#  If we have straight or straight flush, we only need to check the highest card, so there are no additional numbers.
		#  If we have a boat, we have one number for the trips, then another number for the pair.
		#  If we have quads, we have the quads card, then the kicker.

	var r = ["highCard", "pair-", "2pair-", "trips-", "straight", "flush", "boat", "quads-", "straightFlush"]
	var result := " Player 1's best hand: " + " "
#	result.join(str(x) for x in p1H)
	result += str(p1H.slice(0,4))
	result = result.replace("10","T").replace("11","J").replace("12","Q").replace("13","K").replace("14","A").replace("51",r[0]).replace("52 ",r[1]).replace("53",r[2]).replace("54",r[3]).replace("55",r[4]).replace("56",r[5]).replace("57",r[6]).replace("58",r[7]).replace("59",r[8])
	print(result)
	print(p1H.slice(6,8))
