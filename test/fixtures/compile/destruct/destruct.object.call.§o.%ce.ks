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

getLine(new Position(1, 1))