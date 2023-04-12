require expect: func

type IPosition = {
	line: Number
	column: Number
}

struct Position {
	line: Number
	column: Number
}

func getLine(position: IPosition) {
	return position.line
}

func newPosition() {
	return Position.new(1, 1)
}

expect(getLine(newPosition())).to.eql(1)