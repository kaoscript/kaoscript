extern console: {
	log(...args)
}

func log(...args) {
	console.log(...args)
}

var dyn logHello = log^^()

logHello('foo')