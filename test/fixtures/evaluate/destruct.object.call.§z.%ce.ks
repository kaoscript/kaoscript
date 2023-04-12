require expect: func

type IPosition = {
	line: Number
	column: Number
}

class Position {
	public {
		@line: Number
		@column: Number
	}
	constructor(@line, @column)
}

func getLine(position: IPosition) {
	return position.line
}

func newPosition() {
	return Position.new(1, 1)
}

expect(getLine(newPosition())).to.eql(1)