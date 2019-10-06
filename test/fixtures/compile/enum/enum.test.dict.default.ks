enum Color {
	Red
	Green
	Blue
}

class Foobar {
	private {
		_colors: Dictionary	= {}
	}
	isRed(name) => @colors[name] == Color::Red
}