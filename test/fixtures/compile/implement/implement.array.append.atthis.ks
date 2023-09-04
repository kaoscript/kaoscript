extern sealed class Array

impl Array {
	contains(item, from = 0) { # {{{
		return @indexOf(item, from) != -1
	} # }}}
	pushUniq(...args) { # {{{
		if args.length == 1 {
			if !@contains(args[0]) {
				@push(args[0])
			}
		}
		else {
			for var item in args {
				if !@contains(item) {
					@push(item)
				}
			}
		}
		return this
	} # }}}
	appendUniq(...args) {
		for var arg in args {
			if arg is Array {
				@pushUniq(...arg)
			}
			else {
				@pushUniq(arg)
			}
		}

		return this
	}
}