extern sealed class Array

require expect: func

impl Array {
	append(...args): Array {
		for var i from 0 to~ args.length {
			if args[i] is Array {
				this.push(...args[i])
			}
			else {
				this.push(args[i])
			}
		}

		return this
	}
}

expect([1, 2, 3].append([4, 5, 6], [7, 8, 9], 10, 11, [12, 13, 14])).to.eql([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14])