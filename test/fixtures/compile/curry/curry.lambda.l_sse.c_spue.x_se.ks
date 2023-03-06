extern console

var f = ((prefix: String, name: String): String => prefix + name)^^('Hello ', ^)

console.log(`\(f('White'))`)