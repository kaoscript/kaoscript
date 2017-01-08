abstract class AbstractGreetings {
	private {
		_message: string = ''
	}
	
	$create() {
		this('Hello!')
	}
	
	$create(@message)
	
	abstract greet(name): String
}

class Greetings extends AbstractGreetings {
	greet(name: Number): String {
	}
}