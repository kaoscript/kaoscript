func foo(x, y) async => x - y

func bar() async {
	let d = 0
	
	try {
		d = await foo(42, 24)
		
		d *= 3
	}
	
	return d
}