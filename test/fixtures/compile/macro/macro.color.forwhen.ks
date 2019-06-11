export class Color {
	macro registerSpace(@expression: Object) {
		const fields: Array = []
		const methods: Array = []

		let field
		for component, name of expression.components when !component.family {
			field = `_\(name)`

			fields.push(macro private #i(field): Number)

			methods.push(macro {
				#i(name)() => this.getField(#(name))
				#i(name)(value) => this.setField(#(name), value)
			})

			expression.components[name].field = field
		}

		macro {
			Color.registerSpace(#(expression))

			impl Color {
				#b(fields)
				#b(methods)
			}
		}
	}
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