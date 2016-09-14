extern console: {
	log(...args)
}

extern RangeError

try {
	console.log('foobar')
}
on RangeError {
	console.log('RangeError')
}
catch {
	console.log('Error')
}