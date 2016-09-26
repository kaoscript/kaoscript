extern console

extern final class Array

impl Array {
	last(index = 1) {
		return this.length ? this[this.length - index] : null
	}
}

console.log([1, 2, 3].last())