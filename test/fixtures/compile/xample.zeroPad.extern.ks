extern sealed class Number {
	toString(): String
}

impl Number {
	zeroPad(length): String => this.toString().lpad(length, '0')
}

extern sealed class String {
}

impl String {
	lpad(length, pad): String => pad.repeat(length - this.length) + this
}