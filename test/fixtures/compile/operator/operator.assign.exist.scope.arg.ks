extern console, context

func foo(this) {
	return this.message
}

var dyn bar

bar ?= foo*$(context)

console.log(foo, bar)