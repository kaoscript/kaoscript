class Foobar {
	toString(): String => 'foobar'
}

func foobar(): Foobar => Foobar.new()

func qux(x: String): String => x

func qux(x: Foobar): Foobar => x

export foobar, qux