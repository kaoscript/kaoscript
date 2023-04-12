extern console

tuple Pair(String, Number)

var pair = Pair.new('x', 0.1)

var [x, y] = pair

console.log(`\(x)`, y + 1)