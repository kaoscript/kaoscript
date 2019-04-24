extern class Foobar {
	toString(): String
}

func foobar(x: String): String => x

func foobar(x: Foobar): Foobar => x

export foobar