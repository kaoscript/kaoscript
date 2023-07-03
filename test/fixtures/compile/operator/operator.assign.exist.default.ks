extern console: {
	log(...args)
}

var dyn foo = 'otto'
var dyn bar

bar ?= foo

console.log(foo, bar)