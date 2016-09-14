#![cfg(parameters='es6')]

extern console: {
	log(...args)
}

func foo(x, y = 1, ...args) {
	console.log(x, y, args)
}