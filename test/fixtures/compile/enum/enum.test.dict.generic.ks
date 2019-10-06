enum Color {
	Red
	Green
	Blue
}

class Foobar {
	private {
		_colors: Dictionary<Color>	= {}
	}
	isRed(name) => @colors[name] == Color::Red
}