extern console

class LetterBox {
	private {
		_messages: Array<String>
	}

	constructor(@messages)

	build() => [this.format(message) for var message in this._messages]

	format(message: String) => message.toUpperCase()
}