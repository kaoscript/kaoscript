#![libstd(off)]

var PI = 3.14

require|import '../_/_array.ks' for Array

impl Array {
	contains(item, from = 0) {
		return this.indexOf(item, from) != -1
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