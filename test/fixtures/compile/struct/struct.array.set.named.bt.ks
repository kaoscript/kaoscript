extern console

struct Pair(String, Number)

const pair = Pair('x', 0.1)

console.log(`\(pair.0)`, `\(pair.1)`)

pair.0 = 3.14

console.log(`\(pair.0)`, `\(pair.1)`)