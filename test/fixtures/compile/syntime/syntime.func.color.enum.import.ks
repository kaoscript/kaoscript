import '../export/export.enum.space.ks'

class Color {
	syntime func registerSpace(expression: Object) {
		if ?expression.components {
			var fields: Array = []
			var methods: Array = []

			var dyn field
			for var component, name of expression.components {
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
		else {
			quote Color.addSpace(#(expression))
		}
	}
	static addSpace(data)
	getField(name)
	setField(name, value)
}

impl Space {
	HSB
	HSL
}

Color.registerSpace({
	name: Space.HSL
	components: {
		hue: {
			family: Space.HSB
		}
		saturation: {
			family: Space.HSB
		}
		lightness: {
			max: 100
			round: 1
		}
	}
})