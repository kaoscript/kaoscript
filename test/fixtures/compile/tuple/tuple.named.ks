extern console

tuple Pair {
	x: String	= ''
	y: Number	= 0
}

var pair = Pair.new('x', 0.1)

console.log(`\(pair.x)`, pair.y + 1)