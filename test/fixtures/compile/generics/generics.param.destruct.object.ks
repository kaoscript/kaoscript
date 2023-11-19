type Position = {
	line: Number
	column: Number
}

type Event<T> = {
	value: T
	line: Number
	column: Number
}

type Data = {
	value: Number
}

func getPosition(
	{ line, column }: Event<Data>
): Position {
	echo(line + column)

	return {
		line
		column
	}
}