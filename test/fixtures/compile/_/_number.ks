extern isNaN, Math, parseFloat, parseInt

extern sealed class Number {
}

impl Number {
	limit(min, max): Number {
		return isNaN(this) ? min : Math.min(max, Math.max(min, this))
	}
	mod(max): Number {
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
	round(precision = 0): Number {
		precision = Math.pow(10, precision).toFixed(0)
		return Math.round(this * precision) / precision
	}
	toFloat(): Number => parseFloat(this)
	toInt(base = 10): Number => parseInt(this, base)
}

export Number