extern console: {
	log(...args)
}

let foo = { bar: 'hello', baz: 3 }

let bar = 0

{bar, baz} = foo

console.log(bar)
// <- 'hello'

console.log(baz)
// <- 3