extern console: {
	log(...args)
}

let foo = {
	message: 'hello'
}

if (message = foo.message).length > 0 {
	console.log(message)
}