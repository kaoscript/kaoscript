func reverse(value: String): String => value.split('').reverse().join('')
func reverse(value: Array): Array => value.slice().reverse()

const foo = reverse(42)