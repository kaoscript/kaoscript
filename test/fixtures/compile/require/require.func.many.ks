#![libstd(off)]

extern console

require {
	func reverse(value: Array): Array
	func reverse(value: String): String
}

import {
	'../_/_array.ks'
	'../_/_number.ks'
	'../_/_string.ks'
}

func reverse(value: Number): Number => -value

console.log(reverse(42).mod(16))
console.log(reverse('42').toInt())
console.log(reverse([1, 2, 3]).last())

export reverse