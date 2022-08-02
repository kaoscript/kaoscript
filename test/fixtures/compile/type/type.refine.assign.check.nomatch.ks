extern console

func foo(): Number => 42

var dyn x: String = ''

console.log(`\(x)`)

x = 'foobar'

console.log(`\(x)`)

x = foo()

console.log(`\(x)`)