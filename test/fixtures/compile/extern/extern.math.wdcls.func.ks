extern system namespace Math

disclose Math {
	pow(...): Number
}

func foobar(x: Number) {
	return Math.pow(2, x)
}