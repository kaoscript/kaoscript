extern console: {
	log(...)
}

var dyn foo = { bar: 'hello', baz: 3 }

var dyn {bar, baz} = foo

console.log(bar)
// <- 'hello'

console.log(baz)
// <- 3