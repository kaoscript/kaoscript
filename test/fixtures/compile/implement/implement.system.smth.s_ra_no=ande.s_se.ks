extern system class Function

impl Function {
	static curry(fn: String, ...args, *bind? = null)
}

Function.curry('', 'Hello ')