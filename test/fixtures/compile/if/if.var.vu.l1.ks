extern console: {
	log(...args)
}

var dyn foo = {
	message: 'hello'
}

if (message = foo.message).length > 0 {
	console.log(message)
}