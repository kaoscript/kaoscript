#![libstd(off)]

#[rules(non-exhaustive)]
extern system class Function {
	toString(): String
}

impl Function {
	static {
		vcurry(self: func, bind? = null, ...args) => (...additionals) => self.apply(bind, args.concat(additionals))
	}
	toSource(): String => this.toString()
}

export Function