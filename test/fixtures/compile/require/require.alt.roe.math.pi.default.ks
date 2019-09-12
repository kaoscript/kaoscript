require|extern sealed class Number {
	toString(): String
}

#[rules(non-exhaustive)]
require|extern sealed namespace Math {
	PI: Number
}

extern console

console.log(`\(Math.PI.toString())`)

impl Number {
	round(precision: Number = 0): Number {
		precision = Math.pow(10, precision).toFixed(0)
		return Math.round(this * precision) / precision
	}
}

console.log(`\(Math.PI.round().toString())`)

export Number, Math