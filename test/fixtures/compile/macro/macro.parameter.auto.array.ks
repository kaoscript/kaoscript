extern console

macro foobar(@x: Array) {
	macro #(x)
}

console.log(foobar([4, 2]))