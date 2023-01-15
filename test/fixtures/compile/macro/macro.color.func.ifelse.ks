#![rules(ignore-misfit)]

export class Color {
	macro registerSpace(@expression: Object) {
		macro Color.addSpace(#(expression))
	}
}

Color.registerSpace({
	name: 'FBQ'
	formatters: {
		srgb(that: Color): String {
			if that._foo {

			}
			else if that._bar {

			}

			return ''
		}
	}
})