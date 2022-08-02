extern console: {
	log(...args)
}

func log(...args) {
	console.log(...args)
}

var messages = ['hello', 'world']

log**(...messages)