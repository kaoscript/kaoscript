extern console

extern sealed class Function {
	static curry(fn: Function, ...args): Function
}

let fn = (prefix: String, name: String): String => prefix + name

fn = Function.curry(fn, 'Hello ')

console.log(`\(fn('White'))`)