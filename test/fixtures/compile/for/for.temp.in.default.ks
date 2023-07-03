extern console

func foo(x) {
	var dyn value

	if ?x.foo {
		for value in x.foo {
			console.log(value)
		}
	}

	if ?x.bar {
		for value in x.bar {
			console.log(value)
		}
	}
}