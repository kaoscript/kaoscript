extern console: {
	log(...)
}

var dyn key = 'qux'

var dyn { [key] % foo } = { qux: 'bar' }

console.log(foo)
// <- 'bar'