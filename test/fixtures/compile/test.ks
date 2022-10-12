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



// class ClassA {
// }
// class ClassB extends ClassA {
// }

// func foobar(x: ClassB? = null, y: ClassA) {
// }

// foobar(new ClassB())
