extern {
	console: {
		log(...args)
	}
}

func blend(x: Number, y: Number, percentage: Number) -> Number {
	return (1 - percentage) * x + percentage * y
}