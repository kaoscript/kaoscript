extern console

struct Pair(String, Number)

const pair = new Pair('x', 0.1)

const [x, y] = pair

console.log(`\(x)`, y + 1)