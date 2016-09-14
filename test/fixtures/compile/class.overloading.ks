extern console: {
	log(...args)
}

class Greetings {
	foo(...args) {
		console.log(args)
	}
	bar() {
	}
	bar(name, ...messages) {
		console.log(name, messages)
	}
	baz() {
	}
	baz(foo, bar = 'bar', qux = 'qux') {
		console.log(foo, bar, qux)
	}
	qux() {
	}
	qux(name, priority = 1, ...messages) {
		console.log(name, priority, messages)
	}
	corge(name) {
		console.log(name)
	}
	corge(name, message, priority = 1) {
		console.log(name, priority, message)
	}
	grault(name) {
		console.log(name)
	}
	grault(name, priority = 1, message) {
		console.log(name, priority, message)
	}
	garply(name: string) {
		console.log(name)
	}
	garply(name: string, message: string, priority: Number = 1) {
		console.log(name, priority, message)
	}
	garply(name: string, priority: Number = 1, messages: array) {
		console.log(name, priority, messages)
	}
	waldo() {
	}
	waldo(name, ...messages, priority = 1) {
		console.log(name, priority, messages)
	}
}