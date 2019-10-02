class Foobar {
	message(x): String => x.toString():String
}

class Quxbaz extends Foobar {
	message(x: String) => x
	message(x: Number) => `\(x)`
	message(x): String => 'null'
}