extern console: {
	log(...args)
}

func log(this: { log(...args) }, ...args) {
	this.log(...args)
}

var messages = ['hello', 'world']

log*$(console, ...messages)