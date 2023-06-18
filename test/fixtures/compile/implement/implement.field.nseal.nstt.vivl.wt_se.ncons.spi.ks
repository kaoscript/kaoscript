import './implement.field.nseal.gss.ks'

extern console

impl Shape {
	private {
		final late @name: String
	}
	name(): @name
	toString(): String => `I'm drawing a \(@color) \(@name).`
}

var shape = Shape.makeBlue()

console.log(shape.toString())