extern console: {
	log(...args)
}

var dyn foo = {
	message: 'hello'
}

var dyn message

if (message <- foo.message).length > 0 {
	console.log(message)
}