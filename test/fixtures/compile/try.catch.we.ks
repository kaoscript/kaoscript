extern console: {
	log(...args)
}

try {
	console.log('foobar')
}
catch(error) {
	console.log(error)
}