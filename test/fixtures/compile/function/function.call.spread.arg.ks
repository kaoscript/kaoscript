extern console: {
	log(...args)
}

func log(...args) {
	this.log(...args)
}

var messages = ['hello', 'world']

log*$(console, ...messages)