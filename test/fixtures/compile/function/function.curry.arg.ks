extern console: {
	log(...args)
}

var dyn log = console.log^$(console, ...['hello: '])

log('foo')