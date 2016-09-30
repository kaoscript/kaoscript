extern console: {
	log(...args)
}

func log(...args) {
	console.log(...args)
}

let logHello = log^^('hello: ')

logHello('foo')