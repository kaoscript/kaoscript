extern console

func reverse(value: String): String => value.split('').reverse().join('')
func reverse(value: Array): Array => value.slice().reverse()

func foobar(x: Array | String) {
	console.log(`\(reverse(x))`)
}