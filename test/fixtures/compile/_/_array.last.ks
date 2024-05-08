#![libstd(off)]

require system class Array

impl Array {
	last(index: Number = 1) {
		return if this.length != 0 set this[this.length - index] else null
	}
}

export Array