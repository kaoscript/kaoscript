// import 'path' as {
// 	var sep: String
// }

// func foobar(): String => path.sep



// import 'path' {
// 	func basename(path: String): String
// }

// path.basename('')



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



// class Color {
// 	static {
// 		from(...args): Color | Boolean {
// 			return false
// 		}
// 	}

// 	readable(color: Color, tripleA: Boolean = false): Boolean {
// 		return false
// 	}
// }

// Color.from('#abc').readable(Color.from('#963')!!)