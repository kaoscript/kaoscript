import '../export/export.enum.space'

class Color {
	macro registerSpace(@expression: Object) {
		if expression.components? {
			const fields: Array = []
			const methods: Array = []

			let field
			for component, name of expression.components {
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
		else {
			macro Color.registerSpace(#(expression))
		}
	}
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