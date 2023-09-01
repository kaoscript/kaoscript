extern console

var dyn foo = {
	foo: func() {
		var dyn i = 0
	}
}

func bar() {
	for i from 0 to~ 10 {
		console.log(i)
	}
}