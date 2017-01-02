#![cfg(format(destructuring='es5'))]

extern console: {
	log(...args)
}

let foo = { bar: { n1: 'hello', n2: 'world' } }

let {bar: { n1, n2: qux }} = foo

console.log(n1, qux)
// <- 'hello', 'world'