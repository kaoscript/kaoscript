export class Color {
	macro registerSpace(@expression: Dictionary) {
		const fields: Array = []
		const methods: Array = []

		let field
		for component, name of expression.components when !?component.family {
			field = `_\(name)`

			fields.push(macro private #w(field): Number)

			methods.push(macro {
				#w(name)() => this.getField(#(name))
				#w(name)(value) => this.setField(#(name), value)
			})

			expression.components[name].field = field
		}

		macro {
			Color.registerSpace(#(expression))

			impl Color {
				#s(fields)
				#s(methods)
			}
		}
	}
	static registerSpace(data)
	getField(name)
	setField(name, value)
}

Color.registerSpace!({
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