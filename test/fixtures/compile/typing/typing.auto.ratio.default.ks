import '../_/_number.ks'

extern console: {
	log(...args)
}

type float = Number

func foo(): float {
	return 0.32
}

var mut l1 = foo() + 0.05
var mut l2 = foo() + 0.05

var mut ratio = l1 / l2

console.log(ratio.round(2))