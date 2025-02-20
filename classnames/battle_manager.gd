extends Resource
class_name BattleInfo

@export var deck : Array
@export var cards_in_hand : Array
@export var cards_played : Array

func card_drawn(): 
	cards_in_hand.push_back(deck[0])
	deck.pop_front()

func card_played(card : CardStats):
	cards_played.push_back(card)
	cards_in_hand.erase(card)
	card.when_played()
	
func shuffle_all():
	deck.append_array(cards_in_hand)
	deck.append_array(cards_played)
	deck.shuffle()
	cards_in_hand.clear()
	cards_played.clear()

func shuffle_played_into_deck():
	deck.append_array(cards_played)
	deck.shuffle()
	cards_played.clear()

func add_card_to_deck(card):
	deck.push_back(card)
