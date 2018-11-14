extern sealed class Number {
	toString(): String
}

impl Number {
	zeroPad(): String => '00' + this.toString()
}

type T = {
	PI: Number
}

let Math: T = {
	PI: 3.14
}

Math.PI.zeroPad()