struct Position {
	line: Number
	column: Number
}

func getLine(position: { line: Number, column: Number }) {
	return position.line
}

getLine(Position.new(1, 1))