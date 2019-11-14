#![target(ecma-v5)]

extern console: {
	log(...)
}

foo = { bar: 'hello', baz: 3 }

{bar, baz} = foo

console.log(bar)
// <- 'hello'

console.log(baz)
// <- 3