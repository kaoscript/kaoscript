func foobar(...args) {
	let x = args.pop()
	
	if x != 'a' {
		x = null
	}
	
	quxbaz(x)
}

func quxbaz(x: String = '') {
}