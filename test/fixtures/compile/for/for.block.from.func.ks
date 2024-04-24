var dyn foo = {
	foo: func() {
		var dyn i = 0
	}
}

func bar() {
	for var i from 0 to~ 10 {
		echo(i)
	}
}