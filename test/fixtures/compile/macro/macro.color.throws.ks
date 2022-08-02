export class Color {
	macro registerSpace(@expression: Dictionary) {
		if expression.components? {
			var fields: Array = []
			var methods: Array = []

			var dyn field
			for component, name of expression.components {
				field = `_\(name)`

				fields.push(macro private #w(field): Number = 0)

				methods.push(macro {
					#w(name)() ~ Error => this.getField(#(name))
					#w(name)(value) ~ Error => this.setField(#(name), value)
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
		else {
			macro Color.registerSpace(#(expression))
		}
	}

	static registerSpace(data)

	getField(name) ~ Error {
		throw new Error('Not Implemented')
	}

	setField(name, value) ~ Error {
		throw new Error('Not Implemented')
	}
}

Color.registerSpace!({
	name: 'srgb'
	alias: ['rgb']
	components: {
		red: {
			max: 255
		}
		green: {
			max: 255
		}
		blue: {
			max: 255
		}
	}
})