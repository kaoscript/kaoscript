require expect: func

struct Position {
	line: Number
	column: Number
}

func getLine(position: { line: Number, column: Number }) {
	return position.line
}

func newPosition() {
	return Position.new(1, 1)
}

expect(getLine(newPosition())).to.eql(1)