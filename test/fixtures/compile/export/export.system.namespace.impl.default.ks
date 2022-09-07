extern system console

extern system class Number {
	toString(): String
}

extern system namespace Math {
	PI: Number
	pow(): Number
}

impl Math {
	pi: Number = Math.PI
	foo(): Number => Math.PI
}

export console, Number, Math