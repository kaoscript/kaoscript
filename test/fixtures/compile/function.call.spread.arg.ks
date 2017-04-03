extern console: {
	log(...args)
}

func log(...args) {
	this.log(...args)
}

const messages = ['hello', 'world']

log*$(console, ...messages)