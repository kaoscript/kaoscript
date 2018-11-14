extern console: {
	log(...args)
}

func foo() {
	let x = 42
	
	try {
		console.log('try')
		
		return x
	}
	finally {
		x = 24
		
		console.log('finally', x)
	}
}