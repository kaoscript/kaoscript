class Foobar {
	toString(): String => 'foobar'
}

func foobar(x: String): String => x

func foobar(x: Foobar): Foobar => x

enum Color {
	Red
	Green
	Blue
}

export *