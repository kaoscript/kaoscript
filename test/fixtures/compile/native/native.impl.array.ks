extern console

extern sealed class Array {
	length: Number
}

impl Array {
	last(index: Number = 1) {
		return this.length != 0 ? this[this.length - index] : null
	}
}

console.log([1, 2, 3].last())