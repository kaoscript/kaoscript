extern console: {
	log(...args)
}

let foo = () => 'otto'

bar ?= foo()

console.log(foo, bar)