extern console, context

func foo(this) {
	return this.message
}

bar ?= foo*$(context)

console.log(foo, bar)