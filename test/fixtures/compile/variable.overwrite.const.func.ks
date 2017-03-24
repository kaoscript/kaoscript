extern console, bar

const x = 42

func foo() {
	if x ?= bar() {
		console.log(x)
	}
}