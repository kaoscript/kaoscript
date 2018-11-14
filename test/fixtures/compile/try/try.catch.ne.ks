extern console: {
	log(...args)
}

try {
	console.log('foobar')
}
catch {
	console.log('error')
}