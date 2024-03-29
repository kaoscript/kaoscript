extern console
extern class SyntaxError

class Greetings {
	private {
		_message: string = ''
	}

	constructor() {
		this('Hello!')
	}

	constructor(@message)

	greet(name): String ~ SyntaxError => `\(@message)\nIt's nice to meet you, \(name).`
}

func foo() ~ SyntaxError {
	var hello = Greetings.new('Hello world!')

	console.log(hello.greet('miss White'))
}