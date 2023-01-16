extern console

macro foobar(value) {
	macro console.log(#a(value))
}

foobar(1)