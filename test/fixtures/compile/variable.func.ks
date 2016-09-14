extern console: {
	log(...args)
}

func foo(bar?) {
	if qux ?= bar {
		console.log(qux)
	}
}