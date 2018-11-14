extern console: {
	log(...args)
}

func log(...args) {
	console.log(...args)
}

log**('hello')