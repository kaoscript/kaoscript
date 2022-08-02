extern console: {
	log(...)
}

var dyn foo = { bar: 'hello', baz: 3 }

var dyn {bar: a, baz: b} = foo

console.log(a)
// <- 'hello'

console.log(b)
// <- 3