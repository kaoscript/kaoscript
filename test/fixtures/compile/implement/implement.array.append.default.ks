extern sealed class Array

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
			for item in args {
				if !this.contains(item) {
					this.push(item)
				}
			}
		}
		return this
	} # }}}
	appendUniq(...args) { # {{{
		if args.length == 1 {
			this.pushUniq(...args[0])
		}
		else {
			for i from 0 to~ args.length {
				this.pushUniq(...args[i])
			}
		}
		return this
	} # }}}
}