func foo(x, y) async => x - y

func bar() async {
	let d = await foo(42, 24)
	
	return d * 3
}