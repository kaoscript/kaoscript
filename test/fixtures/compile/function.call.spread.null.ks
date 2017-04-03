extern console: {
	log(...args)
}

func log(...args) {
	console.log(...args)
}

const messages = ['hello', 'world']

log**(...messages)