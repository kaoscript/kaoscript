extern console: {
	log(...args)
}

func log(this: { log(...args) }, ...args) {
	this.log(...args)
}

log*$(console, 'hello')