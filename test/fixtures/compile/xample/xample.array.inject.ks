import '../_/_array.ks'

impl Array {
	injectAt(mut index: Number, ...args): Array {
		if index < 0 {
			do {
				index = this.length + index + 1
			}
			while index < 0
		}

		if args.length > 1 {
			if index != 0 {
				if index >= this.length {
					for i from 0 to~ args.length {
						this.push(...args[i])
					}
				}
				else {
					for i from 0 to~ args.length {
						this.splice(index, 0, ...args[i])

						index += [].concat(args[i]).length
					}
				}
			}
			else {
				for i from args.length - 1 to 0 step -1 {
					this.unshift(...args[i])
				}
			}
		}
		else {
			if index != 0 {
				if index >= this.length {
					this.push(...args[0])
				}
				else {
					this.splice(index, 0, ...args[0])
				}
			}
			else {
				this.unshift(...args[0])
			}
		}

		return this
	}
}