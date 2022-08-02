export class Color {
	macro registerSpace(@expression: Dictionary) {
		var fields: Array = []
		var methods: Array = []

		var dyn field
		for component, name of expression.components {
			field = `_\(name)`

			fields.push(macro private #w(field): Number = 0)

			methods.push(macro {
				#w(name)() => this.getField(#(name))
			})

			if component.mutator != true {
				methods.push(macro {
					#w(name)(value) => this.setField(#(name), value)
				})
			}

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
	static registerSpace(data)
	getField(name)
	setField(name, value)
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
		alpha: {
			mutator: true
		}
	}
})