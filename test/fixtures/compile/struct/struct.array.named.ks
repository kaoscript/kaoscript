extern console

struct Pair [
	x: String	= ''
	y: Number	= 0
]

let pair = new Pair('x', 0.1)

console.log(`\(pair.x)`, pair.y + 1)