#![target(ecma-v5)]

extern console

func foobar() {
	this.foobar = true

	return () => {
		this.arrow = true

		return this
	}
}

console.log(foobar*$({})())