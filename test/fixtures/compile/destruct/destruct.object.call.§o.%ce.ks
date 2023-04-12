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

getLine(Position.new(1, 1))