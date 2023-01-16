extern console

macro foobar(value) {
	macro console.log(#(value))
}

foobar(1, 2)