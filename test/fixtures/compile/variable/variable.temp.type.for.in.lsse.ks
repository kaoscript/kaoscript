import '../_/_string.ks'

extern console

func foo(): String[] => ['1', '8', 'F']

for item in foo() {
	console.log(item.toInt(16))
}