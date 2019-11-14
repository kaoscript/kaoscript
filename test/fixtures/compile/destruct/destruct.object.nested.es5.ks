#![target(ecma-v5)]

extern console: {
	log(...)
}

let foo = { bar: { n1: 'hello', n2: 'world' } }

let {bar: { n1, n2: qux }} = foo

console.log(n1, qux)
// <- 'hello', 'world'