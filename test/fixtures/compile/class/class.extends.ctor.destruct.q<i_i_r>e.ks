type Position = {
	line: Number
	column: Number
	...
}

class Foobar {
	private {
		@message: String
		@line: Number
	}
	constructor(@message, @line) {
	}
	constructor(@message, { line }: Position) {
		this(message, line)
	}
}

class Quxbaz extends Foobar {
	constructor(@message = 'quxbaz', data: Position) {
		super(message, data)
	}
}