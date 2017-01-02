extern console: {
	log(...args)
}

let {foo=3} = { foo: 2 }

console.log(foo)
// <- 2

let {foo=3} = { foo: null }

console.log(foo)
// <- 3

let {foo=5} = { bar: 2 }

console.log(foo)
// <- 5