#![cfg(format(destructuring='es5'))]

extern console: {
	log(...args)
}

func foo() => { bar: 'hello', baz: 3 }

let bar = 0

{bar, baz} = foo()

console.log(bar)
// <- 'hello'

console.log(baz)
// <- 3