extern console: {
	log(...args)
}

let log = console.log^$(console, ...['hello: '])

log('foo')