func foo(x, y) async {
}

func bar() async {
	let d = 0
	
	d = await foo(42, 24)
	
	return d * 3
}