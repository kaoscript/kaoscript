extern console

macro foobar(...args) {
	macro console.log(#(args))
}

foobar(1, 2, 3)