#[rules(non-exhaustive)]
extern sealed class Array {
	length: Number
	indexOf(value?, from: Number = 0): Number
	push(...values?)
}

impl Array {
	contains(item, from = 0) { # {{{
		return this.indexOf(item, from) != -1
	} # }}}
	pushUniq(...args) { # {{{
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
	} # }}}
}