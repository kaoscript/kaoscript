require Helper, Type

extern sealed class Function {
}

impl Function {
	static {
		vcurry(self: func, bind = null, ...args) {
			return func(...additionals) {
				return self.apply(bind, args.concat(additionals))
			}
		}
	}
}

export Function