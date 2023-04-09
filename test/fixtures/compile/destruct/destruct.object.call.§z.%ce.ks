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

getLine(new Position(1, 1))