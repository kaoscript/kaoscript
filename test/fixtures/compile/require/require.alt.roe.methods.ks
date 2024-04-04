#![libstd(off)]

#[rules(non-exhaustive)]
require|extern system class Array {
	indexOf(...): Number
	push(...): Number
	slice(...): Array
}

impl Array {
	contains(item, from = 0): Boolean {
		return this.indexOf(item, from) != -1
	}
	pushUniq(...args): Array {
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