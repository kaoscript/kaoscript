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

let hello = new AbstractGreetings('Hello world!')