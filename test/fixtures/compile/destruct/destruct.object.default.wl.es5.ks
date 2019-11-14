#![target(ecma-v5)]

extern console: {
	log(...)
}

let foo = { bar: 'hello', baz: 3 }

let {bar, baz} = foo

console.log(bar)
// <- 'hello'

console.log(baz)
// <- 3