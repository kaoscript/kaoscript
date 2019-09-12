extern console, isNaN

extern sealed class Number

impl Number {
	mod(max: Number): Number {
		if isNaN(this) {
			return 0
		}
		else {
			let n = this % max
			if n < 0 {
				return n + max
			}
			else {
				return n
			}
		}
	}
}

console.log(42.mod(3))