enum Space<String> {
	RGB
	SRGB
	YUV
}

class Color {
	macro registerSpace(@expression: Dictionary) {
		if expression.components? {
			var fields: Array = []
			var methods: Array = []

			var dyn field
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

Color.registerSpace!({
	name: Space::SRGB
	alias: [Space::RGB]
	parsers: {
		from: {
			[Space::YUV]() {
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