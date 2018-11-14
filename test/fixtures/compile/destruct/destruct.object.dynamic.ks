extern console: {
	log(...args)
}

let key = 'qux'

let { [key]: foo } = { qux: 'bar' }

console.log(foo)
// <- 'bar'