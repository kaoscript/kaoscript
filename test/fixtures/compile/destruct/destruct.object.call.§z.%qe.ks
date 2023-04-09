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

getLine(new Position(1, 1))