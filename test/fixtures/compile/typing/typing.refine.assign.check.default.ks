extern console

func foo(): String => ''

var dyn x = ''

console.log(`\(x)`)

x = foo()

console.log(`\(x)`)

var dyn y = 42

console.log(`\(y)`)

y = foo()

console.log(`\(y)`)

export foo, x, y