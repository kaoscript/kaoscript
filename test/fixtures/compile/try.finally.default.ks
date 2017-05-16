extern console: {
	log(...args)
}

try {
	console.log('foobar')
}
finally {
	console.log('finally')
}