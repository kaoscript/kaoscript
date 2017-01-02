#![cfg(parse(parameters='kaoscript'))]

extern console: {
	log(...args)
}

func foo(x, y = 1, ...args, z) {
	console.log(x, y, args, z)
}