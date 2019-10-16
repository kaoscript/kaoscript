extern $hex

enum Space<String> {
	RGB
	SRGB
}

export class Color {
	private {
		_alpha: Number
	}
	macro registerSpace(@expression: Dictionary) {
		if expression.components? {
			const fields: Array = []
			const methods: Array = []

			let field
			for component, name of expression.components {
				field = `_\(name)`

				fields.push(macro private #w(field): Number)

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
	formatters: {
		hex: (that: Color): String => $hex(that)
		srgb: (that: Color): String => { // {{{
			if that._alpha == 1 {
				return 'rgb(' + that._red + ', ' + that._green + ', ' + that._blue + ')'
			}
			else {
				return 'rgba(' + that._red + ', ' + that._green + ', ' + that._blue + ', ' + that._alpha + ')'
			}
		} // }}}
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