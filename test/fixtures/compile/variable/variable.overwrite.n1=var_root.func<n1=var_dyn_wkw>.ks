extern console, bar

var x = 42

func foo() {
	#[overwrite] var dyn x

	if x ?= bar() {
		console.log(x)
	}
}