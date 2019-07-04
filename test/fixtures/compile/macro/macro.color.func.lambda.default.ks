extern $hex

enum Space<String> {
	RGB
	SRGB
}

export class Color {
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

Color.registerSpace!({
	name: Space::SRGB
	alias: [Space::RGB]
	formatters: {
		hex: that => $hex(that)
		srgb: that => { // {{{
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