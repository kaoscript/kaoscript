enum Token {
	INVALID
}

class Scanner {
	match(...tokens: Array<Token>) {
		const c = this.skip(tokens.length)

		return Token::INVALID
	}
	private skip(index) {
	}
}