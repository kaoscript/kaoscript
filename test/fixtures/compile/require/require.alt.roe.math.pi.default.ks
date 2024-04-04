#![libstd(off)]

require|extern system class Number {
	toString(): String
}

#[rules(non-exhaustive)]
require|extern system namespace Math {
	PI: Number
	round(...): Number
}

extern console

console.log(`\(Math.PI.toString())`)

impl Number {
	round(mut precision: Number = 0): Number {
		precision = Math.pow(10, precision).toFixed(0)
		return Math.round(this * precision) / precision
	}
}

console.log(`\(Math.PI.round().toString())`)

export Number, Math