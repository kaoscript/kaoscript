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

const hello = new Greetings('Hello world!')

console.log(hello.greet('miss White'))