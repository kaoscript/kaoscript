import * from './_number.ks'

extern console: {
	log(...args)
}

type float = Number

func foo(): float {
	return 0.32
}

let l1 := foo() + 0.05
let l2 := foo() + 0.05

let ratio := l1 / l2

console.log(ratio.round(2))