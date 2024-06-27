#![rules(ignore-misfit)]

export class Color {
	syntime func registerSpace(expression: Object) {
		quote Color.addSpace(#(expression))
	}
}

Color.registerSpace({
	name: 'FBQ'
	formatters: {
		srgb: func(that: Color): String {
			if that._foo {

			}
			else if that._bar {

			}

			return ''
		}
	}
})