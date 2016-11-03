extern console, context

func foo() {
	return this.message
}

bar ?= foo*$(context)

console.log(foo, bar)