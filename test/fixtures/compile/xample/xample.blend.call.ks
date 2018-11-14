import '../_/_number.ks'

extern {
	console: {
		log(...args)
	}
}

type float = Number

func blend(x: float, y: float, percentage: float): float {
	return (1 - percentage) * x + percentage * y
}

console.log(blend(0.8, 0.5, 0.3).round(2))