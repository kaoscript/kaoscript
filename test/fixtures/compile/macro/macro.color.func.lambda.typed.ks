extern $hex

enum Space<String> {
	RGB
	SRGB
}

export class Color {
	private {
		_alpha: Number	= 1
	}
	macro registerSpace(@expression: Object) {
		if ?expression.components {
			var fields: Array = []
			var methods: Array = []

			var dyn field
			for var component, name of expression.components {
				field = `_\(name)`

				fields.push(macro private #w(field): Number = 0)

				methods.push(macro {
					#w(name)() => this.getField(#(name))
					#w(name)(value) => this.setField(#(name), value)
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
	getField(name)
	setField(name, value)
}

Color.registerSpace({
	name: Space.SRGB
	alias: [Space.RGB]
	formatters: {
		hex: (that: Color): String => $hex(that)
		srgb: (that: Color): String => { # {{{
			if that._alpha == 1 {
				return 'rgb(' + that._red + ', ' + that._green + ', ' + that._blue + ')'
			}
			else {
				return 'rgba(' + that._red + ', ' + that._green + ', ' + that._blue + ', ' + that._alpha + ')'
			}
		} # }}}
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