extern console, bar

var x = 42

func foo() {
	var dyn x

	if x ?= bar() {
		console.log(x)
	}
}