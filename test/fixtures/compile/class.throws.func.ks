extern console
extern class SyntaxError

class Greetings {
	private {
		_message: string = ''
	}
	
	$create() {
		this('Hello!')
	}
	
	$create(@message)
	
	greet(name): String ~ SyntaxError => `\(@message)\nIt's nice to meet you, \(name).`
}

func foo() ~ SyntaxError {
	const hello = new Greetings('Hello world!')
	
	console.log(hello.greet('miss White'))
}