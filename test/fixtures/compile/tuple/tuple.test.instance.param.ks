extern console

tuple Pair [ :String, :Number ]

func foobar(pair: Pair) {
	console.log(`\(pair.0)`, pair.1 + 1)
}

foobar(Pair.new('x', 0.1))