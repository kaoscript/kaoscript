extern console: {
	log(...args)
}

import './_color.default.ks' for Color => C, Space => S
console.log(C, S)

import './_color.cie.ks'(Color: C, Space: S) for Color => C, Space => S
console.log(C, S)