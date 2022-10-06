extern console

extern sealed class Function {
	static curry(fn: Function, ...args): Function
}

var fn = (prefix: String, name: String): String => prefix + name

var cr = Function.curry(fn, 'Hello ')

console.log(`\(cr('White'))`)