extern console

var f = (prefix: String, name: String): String => prefix + name
var g = f^^('Hello ', ^)

console.log(`\(f('Hello ', 'White'))`)
console.log(`\(g('White'))`)