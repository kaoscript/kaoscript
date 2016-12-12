extern sealed class Number {
	toString(): String
}

extern sealed Math: {
	PI: Number
	pow(): Number
}

impl Math {
	pi: Number = Math.PI
	foo(): Number => Math.PI
}

Math.pi
Math.foo()