import * from ./_string

extern console

func foo(): Array<String> => ['1', '8', 'F']

for item in foo() {
	console.log(item.toInt(16))
}