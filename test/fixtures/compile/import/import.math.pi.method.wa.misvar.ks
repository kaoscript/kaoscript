#![libstd(off)]

extern system class Number {
	toString(): String
}

extern system namespace Math

extern console

import '../require/require.alt.roe.math.pi.default.ks'(Number, Math)

console.log(`\(Math.PI.toString())`)
console.log(`\(Math.PI.round().toString())`)