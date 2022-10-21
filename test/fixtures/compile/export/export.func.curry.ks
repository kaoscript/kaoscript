impl Function {
	static curry(fn: Function, ...args, *bind? = null): Function => (...newArgs) => fn*$(bind, ...args, ...newArgs)
}

export Function