extern console

#[rules(non-exhaustive)]
extern sealed class Array {
	toString(): String
}

func reverse(value: String): String => value.split('').reverse().join('')
func reverse(value: Array): Array => value.slice().reverse()

var foo = reverse([1, 2, 3])

console.log(`\(foo.toString())`)