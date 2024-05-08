extern console

extern sealed class Array {
	length: Number
}

impl Array {
	last(index: Number = 1) {
		return if this.length != 0 set this[this.length - index] else null
	}
}

console.log([1, 2, 3].last())