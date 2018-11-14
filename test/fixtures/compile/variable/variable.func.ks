extern console: {
	log(...args)
}

func foo(bar = null) {
	if qux ?= bar {
		console.log(qux)
	}
}