export class Color {
	syntime func registerSpace(expression: Object) {
		var fields: Array = []
		var methods: Array = []

		var dyn field
		for var component, name of expression.components when !?component.family {
			field = `_\(name)`

			fields.push(quote private #w(field): Number = 0)

			methods.push(quote {
				#w(name)() => this.getField(#(name))
				#w(name)(value) => this.setField(#(name), value)
			})

			expression.components[name].field = field
		}

		quote {
			Color.addSpace(#(expression))

			impl Color {
				#s(fields)
				#s(methods)
			}
		}
	}
	static addSpace(data)
	getField(name)
	setField(name, value)
}

Color.registerSpace({
	name: 'srgb'
	alias: ['rgb']
	components: {
		red: {
			family: 'foobar'
		}
		green: {
			max: 255
		}
		blue: {
			family: 'foobar'
		}
	}
})