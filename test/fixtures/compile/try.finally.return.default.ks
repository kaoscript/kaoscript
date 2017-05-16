extern console: {
	log(...args)
}

func foo() {
	try {
		console.log('try')
		
		return 42
	}
	finally {
		console.log('finally')
	}
}