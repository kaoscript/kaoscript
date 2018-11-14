extern console, bar

const x = 42

func foo() {
	let x
	
	if x ?= bar() {
		console.log(x)
	}
}