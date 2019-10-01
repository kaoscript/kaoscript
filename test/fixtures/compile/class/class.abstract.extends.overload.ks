abstract class AbstractGreetings {
	abstract message(): String
}

class Greetings extends AbstractGreetings {
	private {
		@message: String
	}
	message() => @message
	message(@message) => this
}