extern system class Array

disclose Array {
	length: Number
	push(...elements): Number
}

impl Array {
	append(...args): Array {
		for var i from 0 up to~ args.length {
			if args[i] is Array {
				@push(...args[i])
			}
			else {
				@push(args[i])
			}
		}

		return this
	}
}