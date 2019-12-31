extern systemic console

extern systemic class Number {
	toString(): String
}

extern systemic namespace Math {
	PI: Number
	pow(): Number
}

impl Math {
	pi: Number = Math.PI
	foo(): Number => Math.PI
}

export console, Number, Math