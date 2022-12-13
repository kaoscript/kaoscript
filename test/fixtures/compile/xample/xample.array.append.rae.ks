extern system class Array

disclose Array {
	length: Number
	push(...elements): Number
}

impl Array {
	append(...args): Array {
		for var i from 0 to~ args.length {
			@push(...args[i])
		}

		return this
	}
}