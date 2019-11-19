extern console

struct Pair(String, Number)

func foobar(pair: Pair) {
	console.log(`\(pair.0)`, pair.1 + 1)
}

foobar(Pair('x', 0.1))