require expect: func

class Position {
	public {
		@line: Number
		@column: Number
	}
	constructor(@line, @column)
}

func getLine(position: { line: Number, column: Number }) {
	return position.line
}

func newPosition() {
	return new Position(1, 1)
}

expect(getLine(newPosition())).to.eql(1)