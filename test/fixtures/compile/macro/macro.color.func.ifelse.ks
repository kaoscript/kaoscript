#![rules(ignore-misfit)]

export class Color {
	macro registerSpace(@expression: Dictionary) {
		macro Color.registerSpace(#(expression))
	}
}

Color.registerSpace!({
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