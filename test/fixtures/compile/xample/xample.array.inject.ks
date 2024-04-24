#![libstd(off)]

import '../_/_array.ks'

impl Array {
	injectAt(mut index: Number, ...args): Array {
		if index < 0 {
			do {
				index = this.length + index + 1
			}
			while index < 0
		}

		if index != 0 {
			if index >= this.length {
				for var i from 0 up to~ args.length {
					if args[i] is Array {
						this.push(...args[i])
					}
					else {
						this.push(args[i])
					}
				}
			}
			else {
				for var i from 0 up to~ args.length {
					if args[i] is Array {
						this.splice(index, 0, ...args[i])

						index += args[i].length
					}
					else {
						this.splice(index, 0, args[i])

						index += 1
					}
				}
			}
		}
		else {
			for var i from~ args.length down to 0 {
				if args[i] is Array {
					this.unshift(...args[i])
				}
				else {
					this.unshift(args[i])
				}
			}
		}

		return this
	}
}