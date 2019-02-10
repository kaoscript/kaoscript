require|extern sealed class Array {
	indexOf(...): Number
	push(...): Number
	slice(...): Array
}

impl Array {
	contains(item, from = 0): Boolean { // {{{
		return this.indexOf(item, from) != -1
	} // }}}
	pushUniq(...args): Array { // {{{
		if args.length == 1 {
			if !this.contains(args[0]) {
				this.push(args[0])
			}
		}
		else {
			for item in args {
				if !this.contains(item) {
					this.push(item)
				}
			}
		}
		return this
	} // }}}
}

export Array