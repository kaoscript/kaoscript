enum Space<String> {
	RGB
}

class Color {
	private {
		_blue: Number	= 0
		_green: Number	= 0
		_red: Number	= 0
		_space: Space	= Space::RGB
	}
	space() => @space
	space(@space) => this
}

export Color, Space