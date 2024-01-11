extern system class Object<V, K>

disclose Object<V, K> {
	static {
		keys(obj: Object<V, K>): Array<K>
		values(obj: Object<V, K>): Array<V>
	}
}

enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades
}

func print(values: Number[]) {
}

var $precedence: Object<String, CardSuit> = {
	[CardSuit.Clubs]: 'club'
	[CardSuit.Diamonds]: 'diamond'
}

print(Object.values($precedence))