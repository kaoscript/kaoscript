enum Color {
	Red
	Green
	Blue
}

class Foobar {
	private {
		_colors: Object<Color>	= {}
	}
	isRed(name) => @colors[name] == Color::Red
}