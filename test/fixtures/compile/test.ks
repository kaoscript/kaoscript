// import 'path' as {
// 	var sep: String
// }

// func foobar(): String => path.sep



// import 'path' {
// 	func basename(path: String): String
// }

// path.basename('')




// extern system class Function

// impl Function {
// 	static curry(fn: Function, ...args, *bind? = null): Function => (...newArgs) => fn*$(bind, ...args, ...newArgs)
// }

// var dyn fn = func(prefix, name) {
// 	return prefix + name
// }

// fn = Function.curry(fn, 'Hello ')





// func foobar(props, key, value) {
// 	props[key] ||= value
// }



// extern console

// abstract class Master {
// 	private {
// 		@value: String	= ''
// 	}
// 	abstract value(@value): this
// }

// class Foobar extends Master {
// 	value(): @value
// 	value(@value) => this
// }

// var f = new Foobar()

// console.log(`\(f.value('foobar').value())`)
