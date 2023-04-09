require expect: func

struct Position {
	line: Number
	column: Number
}

func getLine(position: { line: Number, column: Number }) {
	return position.line
}

func newPosition() {
	return new Position(1, 1)
}

expect(getLine(newPosition())).to.eql(1)