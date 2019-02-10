require|extern sealed class Number {
	toString(): String
}

require|extern sealed class String {
}

extern parseFloat, parseInt

impl String {
	toFloat(): Number => parseFloat(this)
	toInt(base = 10): Number => parseInt(this, base)
}

export Number, String