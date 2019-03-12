extern console
extern sealed class String

disclose String {
	split(...): Array<String>
	replace(...): String
	trim(): String
}

func foo(value: String) {
	console.log(`\(value.trim())`)

	const list = value.split(',')

	console.log(`\(list[0])`)
}