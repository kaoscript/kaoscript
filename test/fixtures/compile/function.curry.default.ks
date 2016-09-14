extern console: {
	log(...args)
}

let log = console.log^@('hello: ')

log('foo')