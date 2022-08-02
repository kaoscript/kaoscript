extern console: {
	log(...)
}

var dyn foo = { bar: { n1: 'hello', n2: 'world' } }

var dyn {bar: { n1, n2: qux }} = foo

console.log(n1, qux)
// <- 'hello', 'world'