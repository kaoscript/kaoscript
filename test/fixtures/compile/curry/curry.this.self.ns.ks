extern console: {
	log(...args)
}

var dyn log = console.log^@('hello: ')

log('foo')