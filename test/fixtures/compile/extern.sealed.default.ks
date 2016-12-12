extern sealed class Number {
	toString(): String
}

impl Number {
	zeroPad(): String => '00' + this.toString()
}

extern sealed Math: {
	PI: Number
	pow(...args): Number
}

Math.pow(3, 2).zeroPad()

Math.PI.zeroPad()