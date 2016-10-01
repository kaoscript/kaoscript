extern console

func foo(x) {
	if x.foo? {
		for key, value of x.foo {
			console.log(key, value)
		}
	}
	
	if x.bar? {
		for key, value of x.bar {
			console.log(key, value)
		}
	}
}