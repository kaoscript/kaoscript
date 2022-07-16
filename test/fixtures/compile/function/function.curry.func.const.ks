extern console

extern sealed class Function {
	static curry(fn: Function, ...args): Function
}

const fn = (prefix: String, name: String): String => prefix + name

const cr = Function.curry(fn, 'Hello ')

console.log(`\(cr('White'))`)