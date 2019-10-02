class Foobar {
	static message(x): String => x.toString():String
}

class Quxbaz extends Foobar {
	static message(x: String) => x
	static message(x: Number) => `\(x)`
}