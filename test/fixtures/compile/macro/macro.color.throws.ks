export class Color {
	macro registerSpace(@expression: Object) {
		if ?expression.components {
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
				Color.addSpace(#(expression))

				impl Color {
					#s(fields)
					#s(methods)
				}
			}
		}
		else {
			macro Color.addSpace(#(expression))
		}
	}

	static addSpace(data)

	getField(name) ~ Error {
		throw Error.new('Not Implemented')
	}

	setField(name, value) ~ Error {
		throw Error.new('Not Implemented')
	}
}

Color.registerSpace({
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