extern console

func foo() => ''
func bar(): String => ''

func corge(mut x: String) {
	console.log(`\(x)`)

	x = foo()

	console.log(`\(x)`)

	x = bar()

	console.log(`\(x)`)
}

func grault(mut x) {
	console.log(`\(x)`)

	x = foo()

	console.log(`\(x)`)

	x = bar()

	console.log(`\(x)`)
}

var mut x: String = ''

console.log(`\(x)`)

x = foo()

console.log(`\(x)`)

x = bar()

console.log(`\(x)`)

var dyn y = ''

console.log(`\(y)`)

y = foo()

console.log(`\(y)`)

y = bar()

console.log(`\(y)`)

export corge, grault, x, y