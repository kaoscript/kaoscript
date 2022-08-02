extern console, bar

var x = 42

func foo() {
	if x ?= bar() {
		console.log(x)
	}
}