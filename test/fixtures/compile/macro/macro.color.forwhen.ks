export class Color {
	macro registerSpace(@expression: Object) {
		var fields: Array = []
		var methods: Array = []

		var dyn field
		for component, name of expression.components when !?component.family {
			field = `_\(name)`

			fields.push(macro private #w(field): Number = 0)

			methods.push(macro {
				#w(name)() => this.getField(#(name))
				#w(name)(value) => this.setField(#(name), value)
			})

			expression.components[name].field = field
		}

		macro {
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