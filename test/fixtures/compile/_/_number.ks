extern {
	func parseFloat(...): Number
	func parseInt(...): Number
	func isNaN(...): Boolean

	#[rules(non-exhaustive)]
	systemic class Number {
		toFixed(...): Number
	}

	systemic namespace Math {
		max(...): Number
		min(...): Number
		pow(...): Number
		round(...): Number
	}
}

impl Number {
	limit(min: Number, max: Number): Number {
		return isNaN(this) ? min : Math.min(max, Math.max(min, this))
	}
	mod(max: Number): Number {
		if isNaN(this) {
			return 0
		}
		else {
			var dyn n = this % max
			if n < 0 {
				return n + max
			}
			else {
				return n
			}
		}
	}
	round(precision: Number = 0): Number {
		precision = Math.pow(10, precision).toFixed(0)
		return Math.round(this * precision) / precision
	}
	toFloat(): Number => parseFloat(this)
	toInt(base: Number = 10): Number => parseInt(this, base)
}

export Number