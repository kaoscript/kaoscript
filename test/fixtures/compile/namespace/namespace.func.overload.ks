extern console

namespace Util {
	func reverse(value: String): String => value.split('').reverse().join('')
	func reverse(value: Array): Array => value.slice().reverse()

	export reverse
}

var foo = Util.reverse('hello')

console.log(`\(foo)`)

export Util