class Foobar {
	static lateinit const PI: Number
}

Foobar.PI = 42

const x = Foobar.PI + 3.14

export Foobar