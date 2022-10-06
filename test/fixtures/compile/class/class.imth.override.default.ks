extern console

class LetterBox {
	format(message: String) => message.toUpperCase()
}

impl LetterBox {
	override format(message: String) => message.toLowerCase()
}