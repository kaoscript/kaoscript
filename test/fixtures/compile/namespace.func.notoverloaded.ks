extern console

namespace Util {
	export {
		func reverse(value: String): String => value.split('').reverse().join('')
	}
}

const foo = Util.reverse('hello', 42)

console.log(`\(foo)`)