extern console

extern sealed class Array

impl Array {
	last(index = 1) {
		return this.length ? this[this.length - index] : null
	}
}

console.log([1, 2, 3].last())