enum Color {
	Red
	Green
	Blue
}

class Foobar {
	private {
		_colors: Object	= {}
	}
	isRed(name) => @colors[name] == Color::Red
}