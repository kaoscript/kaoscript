extern $hex

enum Space<String> {
	RGB
	SRGB
}

export class Color {
	private {
		_alpha: Number	= 1
	}
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

func formatToHex(that: Color): String => $hex(that)

func formatToSRGB(that: Color): String { # {{{
	if that._alpha == 1 {
		return 'rgb(' + that._red + ', ' + that._green + ', ' + that._blue + ')'
	}
	else {
		return 'rgba(' + that._red + ', ' + that._green + ', ' + that._blue + ', ' + that._alpha + ')'
	}
} # }}}

Color.registerSpace({
	name: Space.SRGB
	alias: [Space.RGB]
	formatters: {
		hex: formatToHex
		srgb: formatToSRGB
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