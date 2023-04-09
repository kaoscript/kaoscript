struct Position {
	line: Number
	column: Number
}

func getLine(position: { line: Number, column: Number }) {
	return position.line
}

getLine(new Position(1, 1))