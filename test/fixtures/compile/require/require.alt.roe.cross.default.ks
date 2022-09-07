require|extern system class Number {
	toString(): String
}

require|extern system class String {
}

extern parseFloat, parseInt

impl String {
	toFloat(): Number => parseFloat(this)
	toInt(base = 10): Number => parseInt(this, base)
}

export Number, String