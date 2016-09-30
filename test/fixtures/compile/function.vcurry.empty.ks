extern console: {
	log(...args)
}

func log(...args) {
	console.log(...args)
}

let logHello = log^^()

logHello('foo')