import '../export/export.enum.space'

class Color {
	macro registerSpace(@expression: Dictionary) {
		if expression.components? {
			const fields: Array = []
			const methods: Array = []

			let field
			for component, name of expression.components {
				field = `_\(name)`

				fields.push(macro private #w(field): Number = 0)

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
		else {
			macro Color.registerSpace(#(expression))
		}
	}
	static registerSpace(data)
	getField(name)
	setField(name, value)
}

enum Space {
	HSB
	HSL
}

Color.registerSpace!({
	name: Space::HSL
	components: {
		hue: {
			family: Space::HSB
		}
		saturation: {
			family: Space::HSB
		}
		lightness: {
			max: 100
			round: 1
		}
	}
})