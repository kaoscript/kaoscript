extern console: {
	log(...)
}

func foo() => { bar: 'hello', baz: 3 }

var dyn bar = 0
var dyn baz

{bar, baz} = foo()

console.log(bar)
// <- 'hello'

console.log(baz)
// <- 3