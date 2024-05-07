type Position = {
	line: Number
	column: Number
}

type Range = {
	start: Position
	end: Position
}

namespace SyntaxAnalysis {
	type ParsingError = Range & {
		expecteds: String[]
	}
}