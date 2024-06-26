#![libstd(off)]

require|extern system class Array

impl Array {
	contains(item, from = 0) {
		return this.indexOf(item, from) != -1
	}
	copy(): Array {
		return this
	}
	pushUniq(...args) {
		if args.length == 1 {
			if !this.contains(args[0]) {
				this.push(args[0])
			}
		}
		else {
			for var item in args {
				if !this.contains(item) {
					this.push(item)
				}
			}
		}
		return this
	}
}

export Array