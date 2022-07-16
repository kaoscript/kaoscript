#[rules(non-exhaustive)]
extern systemic class Function {
	toString(): String
}

impl Function {
	static {
		vcurry(self: func, bind = null, ...args) => (...additionals) => self.apply(bind, args.concat(additionals))
	}
	toSource(): String => this.toString()
}

export Function