#![cfg(parameters='kaoscript')]

extern console: {
	log(...args)
}

func foo(x, y = 1, ...args, z) {
	console.log(x, y, args, z)
}

#[cfg(parameters='es6')]
func bar(x, y = 1, ...args) {
	console.log(x, y, args)
}

#[cfg(parameters='es5')]
func baz(x, y) {
	console.log(x, y)
}

func qux(x, y = 1, ...args, z) {
	console.log(x, y, args, z)
}