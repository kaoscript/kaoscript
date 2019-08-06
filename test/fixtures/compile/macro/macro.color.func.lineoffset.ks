import '../color'

Color.registerSpace!({
	name: 'rvb',
	components: {
		rouge: {
			max: 255
		},
		vert: {
			max: 255
		},
		blue: {
			max: 255
		}
	}
})

Color.registerSpace!({
	name: 'cmy',
	converters: {
		from: {
			srgb: func(red, green, blue, that) {
				that._cyan = blue
				that._magenta = red
				that._yellow = green
			}
		},
		to: {
			srgb: func(cyan, magenta, yellow, that) {
				that._red = magenta
				that._green = yellow
				that._blue = cyan
			}
		}
	},
	components: {
		cyan: {
			max: 255
		},
		magenta: {
			max: 255
		},
		yellow: {
			max: 255
		}
	}
})