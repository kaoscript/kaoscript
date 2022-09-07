require|extern system class Number {
	toString(): String
}

require|extern system class String {
}

extern {
	func parseFloat(...): Number
	func parseInt(...): Number
}

impl String {
	override toFloat(): Number => parseFloat(this)
	override toInt(base = 10): Number => parseInt(this, base)
}

export Number, String