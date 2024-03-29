import './implement.field.nseal.gss.ks'

extern console

impl Shape {
	private {
		@name: String?
	}
	name(): valueof @name
	name(@name): valueof this
	toString(): String => `I'm drawing a \(@color) \(@name).`
}

var shape = Shape.makeBlue()

console.log(shape.toString())