extern systemic class Number {
	toString(): String
}

extern systemic namespace Math {
	PI: Number
	round(...): Number
}

extern console

import '../require/require.alt.roe.math.pi.default.ks'(Number, Math)

console.log(`\(Math.PI.toString())`)
console.log(`\(Math.PI.round().toString())`)