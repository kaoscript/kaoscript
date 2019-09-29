enum Color {
	Red
	Green
	Blue
}

class Foobar {
	private {
		_colors: Array	= []
	}
	color(index) => @colors[index]
}

func quxbaz(f, x) {
	if f.color(x) == Color::Red {
	}
}