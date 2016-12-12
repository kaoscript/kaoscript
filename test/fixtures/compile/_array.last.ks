require sealed class Array

impl Array {
	last(index = 1) {
		return this.length ? this[this.length - index] : null
	}
}

export Array