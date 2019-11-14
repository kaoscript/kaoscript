#![target(ecma-v5)]

extern console: {
	log(...)
}

let foo = { bar: 'hello', baz: 3 }

let {bar: a, baz: b} = foo

console.log(a)
// <- 'hello'

console.log(b)
// <- 3