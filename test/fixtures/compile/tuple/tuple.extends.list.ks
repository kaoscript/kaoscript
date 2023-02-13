extern console

tuple Pair(String, Number)

tuple Triple(Boolean) extends Pair

var triple = new Triple('x', 0.1, true)

console.log(`\(triple.0)`, triple.1 + 1, !triple.2)

export Pair, Triple