class Foobar {
	toString(): String => 'foobar'
}

func foobar(): Foobar => new Foobar()

func qux(x: String): String => x

func qux(x: Foobar): Foobar => x

export foobar, qux