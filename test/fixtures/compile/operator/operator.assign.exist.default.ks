extern console: {
	log(...args)
}

var dyn foo = 'otto'

bar ?= foo

console.log(foo, bar)