#![format(destructuring='es5')]

extern console: {
	log(...args)
}

let {foo=3} = { foo: 2 }

console.log(foo)
// <- 2

{foo=3} = { foo: null }

console.log(foo)
// <- 3

{foo=5} = { bar: 2 }

console.log(foo)
// <- 5