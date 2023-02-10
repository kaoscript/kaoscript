enum Token {
	INVALID
}

class Scanner {
	match(...tokens: Array<Token>) {
		var c = this.skip(tokens.length)

		return Token.INVALID
	}
	private skip(index) {
	}
}