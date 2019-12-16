require|extern sealed class Number

disclose Number {
	static MAX_VALUE: Number
	static MIN_VALUE: Number
	toExponential(fractionDigits: Number = 0): String
	toFixed(digits: Number = 0): String
	toPrecision(precision: Number = 0): String
	toString(): String
}

export Number