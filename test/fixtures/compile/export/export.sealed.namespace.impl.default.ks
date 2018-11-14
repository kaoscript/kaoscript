extern console

extern sealed class Number {
	toString(): String
}

extern sealed namespace Math {
	PI: Number
	pow(): Number
}

impl Math {
	pi: Number = Math.PI
	foo(): Number => Math.PI
}

export console, Number, Math