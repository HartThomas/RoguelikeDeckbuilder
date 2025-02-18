extends Resource
class_name BattleInfo

@export var cards_in_deck : Array
@export var cards_in_hand : Array
@export var cards_played : Array

func card_drawn(): 
	cards_in_hand.push_back(cards_in_deck[0])
	cards_in_deck.pop_front()

func card_played(card : CardStats):
	cards_played.push_back(card)
	cards_in_hand.erase(card)
	card.when_played()
	
func shuffle_all():
	cards_in_deck.append_array(cards_in_hand)
	cards_in_deck.append_array(cards_played)
	cards_in_deck.shuffle()
	cards_in_hand.clear()
	cards_played.clear()

func shuffle_played_into_deck():
	cards_in_deck.append_array(cards_played)
	cards_in_deck.shuffle()
	cards_played.clear()

func add_card_to_deck(card):
	cards_in_deck.push_back(card)
