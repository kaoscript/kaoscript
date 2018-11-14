extern console: {
	log(...args)
}

func log(...args) {
	this.log(...args)
}

log*$(console, 'hello')