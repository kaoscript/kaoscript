require systemic class Array

impl Array {
	last(index: Number = 1) {
		return this.length != 0 ? this[this.length - index] : null
	}
}

export Array