type Position = {
	line: Number
	column: Number
}

type Result = Position & {
	values: Number[] |  Number | Null
}

export Result