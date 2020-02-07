class Foobar {
	static lateinit const PI: Number
}

const x = Foobar.PI + 3.14

Foobar.PI = 42

export Foobar