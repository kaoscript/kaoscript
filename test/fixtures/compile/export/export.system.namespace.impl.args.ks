extern system console

extern system namespace Math {
	PI: Number
	pow(...): Number
}

impl Math {
	foo(x, y?, z = -1): String => `\(x).\(y).\(z)`
}

export console, Math