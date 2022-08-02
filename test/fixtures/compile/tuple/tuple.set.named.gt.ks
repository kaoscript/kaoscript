extern console

tuple Pair(String, Number)

var pair = Pair('x', 0.1)

console.log(`\(pair.0)`, pair.1 + 1)

pair.0 = 'foobar'
pair.1 = 3.14

console.log(`\(pair.0)`, pair.1 + 1)