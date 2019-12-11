extern console

struct Pair [
	x: String	= ''
	y: Number	= 0
]

struct Triple extends Pair [
	z: Boolean	= false
]

const triple = Triple('x', 0.1, true)

console.log(`\(triple.x)`, triple.y + 1, !triple.z)

export Pair, Triple