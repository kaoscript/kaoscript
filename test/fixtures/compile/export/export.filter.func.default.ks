class Foobar {
	toString(): String => 'foobar'
}

func foobar(x: String): String => x

func foobar(x: Foobar): Foobar => x

export foobar