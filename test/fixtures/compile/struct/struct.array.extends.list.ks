extern console

struct Pair(String, Number)

struct Triple(Boolean) extends Pair

const triple = Triple('x', 0.1, true)

console.log(`\(triple.0)`, triple.1 + 1, !triple.2)

export Pair, Triple