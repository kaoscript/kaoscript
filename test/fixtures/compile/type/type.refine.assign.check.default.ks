extern console

func foo(): String => ''

let x = ''

console.log(`\(x)`)

x = foo()

console.log(`\(x)`)

let y = 42

console.log(`\(y)`)

y = foo()

console.log(`\(y)`)

export foo, x, y