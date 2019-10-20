#![target(ecma-v5)]

extern console: {
	log(...)
}

func foo(item = 1) {
	console.log(item)
}

func bar(item: any = 1) {
	console.log(item)
}

func baz(item: any? = 1) {
	console.log(item)
}

func qux(item: Number = 1) {
	console.log(item)
}

func quux(item: Number? = 1) {
	console.log(item)
}