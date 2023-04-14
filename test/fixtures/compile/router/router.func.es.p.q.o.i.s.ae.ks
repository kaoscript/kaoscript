enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

tuple Pair [ :String, :Number ]

struct Point {
    x: Number
    y: Number
}

func foobar(x: CardSuit) => 'card'
func foobar(x: Pair) => 'pair'
func foobar(x: Point) => 'point'
func foobar(x: Object) => 'object'
func foobar(x: Number) => 'number'
func foobar(x: String) => 'string'
func foobar(x) => 'any'