extern console

var dyn foo = 'bar'

console.log(`\(foo)`)

delete foo

var dyn foo = 42

console.log(`\(foo)`)