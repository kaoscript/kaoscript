enum Space<String> {
	RGB
	SRGB
	YUV
}

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

Color.registerSpace({
	name: Space.SRGB
	alias: [Space.RGB]
	parsers: {
		from: {
			[Space.YUV]: func() {
				return 'RGB -> UYV'
			}
		}
	}
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