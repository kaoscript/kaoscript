extern system class Function

impl Function {
	static curry(fn: String, ...args, *bind? = null)
}

func foobar(fn, ...args) {
	Function.curry(fn, ...args)
}