export class Color {
	macro registerSpace(@expression: Dictionary) {
		if expression.components? {
			const fields: Array = []
			const methods: Array = []

			let field
			for component, name of expression.components {
				field = `_\(name)`

				fields.push(macro private #i(field): Number)

				methods.push(macro {
					#i(name)() ~ Error => this.getField(#(name))
					#i(name)(value) ~ Error => this.setField(#(name), value)
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