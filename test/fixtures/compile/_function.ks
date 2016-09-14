require Class, Type

extern final class Function {
}

impl Function {
	static {
		vcurry(self: func, bind?, ...args) {
			return func(...additionals) {
				return self.apply(bind, args.concat(additionals))
			}
		}
	}
}

export Function