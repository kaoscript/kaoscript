type Position = {
	line: Number
	column: Number
}

struct Event {
	ok: Boolean
	value?				= null
	start: Position?	= null
	end: Position?		= null
}