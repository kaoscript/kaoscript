class Greetings {
	private {
		_message: String = 'Hello!'
	}
	
	constructor()
	
	constructor(@message)
	
	constructor(lines: Array<String>) {
		this(lines.join('\n'))
	}
}