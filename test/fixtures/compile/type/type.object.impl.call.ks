extern sealed class Number {
	toString(): String
}

impl Number {
	zeroPad(): String => '00' + this.toString()
}

type T = {
	PI: Number
}

var mut Math: T = {
	PI: 3.14
}

Math.PI.zeroPad()