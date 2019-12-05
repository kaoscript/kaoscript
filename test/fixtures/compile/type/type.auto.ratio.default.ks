import '../_/_number.ks'

extern console: {
	log(...args)
}

type float = Number

func foo(): float {
	return 0.32
}

auto l1 = foo() + 0.05
auto l2 = foo() + 0.05

auto ratio = l1 / l2

console.log(ratio.round(2))